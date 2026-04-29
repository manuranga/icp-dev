import ballerina/http;
import wso2/icp.runtime.bridge as _;
import ballerinax/metrics.logs as _;

service / on new http:Listener(9090) {

    resource function get greeting() returns string {
        return "Hello, World!";
    }
}
