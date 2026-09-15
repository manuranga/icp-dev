// A claim from submission to payment, shaped to exercise every workflow view the console has:
// activities, a failure review, two human tasks in different roles, a branch, and an event wait.
// State lives in memory — the console reads the runtime, not this map, so a database would only
// add a container to the lab.
import ballerina/log;
import ballerina/workflow;

public type Claim record {|
    string id;
    decimal amount;
    string submittedBy;
    string description?;
    string billUrl?;
|};

type Validation record {|
    boolean plausible;
    string note;
|};

// The string-literal union renders as a choice in the console's generated task form.
type ReviewDecision record {|
    "APPROVE"|"REQUEST_BILL"|"REJECT" outcome;
    string comment?;
|};

type PayApproval record {|
    boolean approved;
    string account?;
    string comment?;
|};

type Receipt record {|
    string reference;
    decimal amount;
|};

type ClaimResult record {|
    string claimId;
    "PAID"|"REJECTED" status;
    string reference?;
    string reason?;
|};

# Parks on the manager's review; when the manager asks for a bill, parks again on the
# `billUploaded` event and reviews once more with the bill attached. Payment is a second
# human gate, in a second role.
@workflow:Workflow
function claimApproval(workflow:Context ctx, Claim claim,
        record {|future<json> billUploaded;|} events) returns ClaimResult|error {
    string wfId = check ctx.getWorkflowId();
    string _ = check ctx->callActivity(recordState, {claimId: claim.id, workflowId: wfId, status: "SUBMITTED"});
    // A negative amount fails here on purpose: the failure raises an ON_FAILURE review in the
    // console's queue, which is the only way to see that half of the queue without an agent.
    Validation v = check ctx->callActivity(validateClaim, {id: claim.id, amount: claim.amount},
            retryPolicy = {userRoles: "MANAGER", title: "Review the failed claim validation"});

    ReviewDecision decision = check ctx->awaitHumanTask("reviewClaim",
            {
                claimId: claim.id,
                amount: claim.amount,
                submittedBy: claim.submittedBy,
                description: claim?.description,
                validation: v.note
            },
            userRoles = "MANAGER", title = "Review claim " + claim.id);

    if decision.outcome == "REQUEST_BILL" {
        string _ = check ctx->callActivity(recordState,
                {claimId: claim.id, workflowId: wfId, status: "BILL_REQUESTED", note: decision?.comment});
        json bill = check wait events.billUploaded;
        claim.billUrl = check bill.url;
        string _ = check ctx->callActivity(recordState,
                {claimId: claim.id, workflowId: wfId, status: "BILL_ATTACHED", note: claim?.billUrl});
        decision = check ctx->awaitHumanTask("reviewClaimWithBill",
                {claimId: claim.id, amount: claim.amount, submittedBy: claim.submittedBy, bill: bill},
                userRoles = "MANAGER", title = "Review claim " + claim.id + " (bill attached)");
    }

    if decision.outcome != "APPROVE" {
        string _ = check ctx->callActivity(recordState,
                {claimId: claim.id, workflowId: wfId, status: "REJECTED", note: decision?.comment});
        return {claimId: claim.id, status: "REJECTED", reason: decision?.comment};
    }

    PayApproval pay = check ctx->awaitHumanTask("approvePayment",
            {claimId: claim.id, amount: claim.amount, payee: claim.submittedBy},
            userRoles = "ACCOUNTANT", title = "Approve payment for claim " + claim.id);
    if !pay.approved {
        string _ = check ctx->callActivity(recordState,
                {claimId: claim.id, workflowId: wfId, status: "PAYMENT_REFUSED", note: pay?.comment});
        return {claimId: claim.id, status: "REJECTED", reason: pay?.comment};
    }

    Receipt receipt = check ctx->callActivity(executePayment,
            {claimId: claim.id, amount: claim.amount, account: pay?.account});
    string _ = check ctx->callActivity(recordState,
            {claimId: claim.id, workflowId: wfId, status: "PAID", note: receipt.reference});
    return {claimId: claim.id, status: "PAID", reference: receipt.reference};
}

@workflow:Activity
function validateClaim(string id, decimal amount) returns Validation|error {
    if amount <= 0d {
        return error("A claim must be for a positive amount");
    }
    return {
        plausible: true,
        note: amount > 1000d ? "High-value claim: a bill is recommended before approval" : "Routine claim"
    };
}

@workflow:Activity
function executePayment(string claimId, decimal amount, string? account) returns Receipt|error {
    return {reference: "PAY-" + claimId, amount: amount};
}

@workflow:Activity
function recordState(string claimId, string workflowId, string status, string? note = ()) returns string|error {
    setState(claimId, workflowId, status, note);
    log:printInfo("claim state recorded", claimId = claimId, status = status);
    return status;
}
