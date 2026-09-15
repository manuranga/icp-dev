// The HTTP surface: start a claim, attach its bill, read the states this integration recorded.
// Everything a human decides happens in the ICP console — this service has no task UI on purpose.
import ballerina/http;
import ballerina/uuid;
import ballerina/workflow;
import ballerinax/metrics.logs as _;
import wso2/icp.runtime.bridge as _;

type NewClaim record {|
    decimal amount;
    string submittedBy = "alice";
    string description?;
|};

type ClaimState record {|
    string claimId;
    string workflowId;
    string status;
    string? note;
|};

service /claims on new http:Listener(8290) {

    # Starts a run. The returned workflow ID is what the console lists.
    resource function post .(NewClaim newClaim) returns json|error {
        string claimId = "CLM-" + uuid:createType4AsString().substring(0, 8).toUpperAscii();
        Claim claim = {
            id: claimId,
            amount: newClaim.amount,
            submittedBy: newClaim.submittedBy,
            description: newClaim?.description
        };
        string workflowId = check workflow:run(claimApproval, input = claim);
        setState(claimId, workflowId, "SUBMITTED", ());
        return {claimId, workflowId, status: "SUBMITTED"};
    }

    # Wakes a run parked on `billUploaded`. Events travel through the owning integration,
    # never through the ICP, so this is the only way to resume that wait.
    resource function post [string workflowId]/bill(record {|string url;|} bill) returns json|error {
        check workflow:sendData(claimApproval, workflowId, "billUploaded", bill.toJson());
        return {attached: true, workflowId};
    }

    resource function get .() returns ClaimState[] {
        lock {
            return states.toArray().clone();
        }
    }
}

isolated map<ClaimState> states = {};

isolated function setState(string claimId, string workflowId, string status, string? note) {
    lock {
        states[claimId] = {claimId, workflowId, status, note};
    }
}
