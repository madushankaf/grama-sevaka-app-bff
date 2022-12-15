import ballerina/http;
import ballerina/log;
import madushankaorg/citizen_api;

configurable string citizenAPIClientSecret = "XikBPFD_gf5JiWC5KebGqXixM3sa";
configurable string citizenAPIClientId = "p2apR7ikIqT8elLivV6yeGOzWjQa";

citizen_api:Client citizen_apiEp = check new (config = {
    auth: {
        clientId: citizenAPIClientId,
        clientSecret: citizenAPIClientSecret
    }
});

type CertificateRequest record {
    string id;
    string address;
    RequestStatus requestStatus;
};

enum RequestStatus {
    NEW,
    PENDING,
    COMPLETED,
    FAILED
}

service /gramaSevakaAPI on new http:Listener(9091) {
    resource function post certificateRequest(@http:Payload CertificateRequest certificateRequest) returns CertificateRequest|error {
        json result = check citizen_apiEp->getNicNic(certificateRequest.id);
        log:printInfo(result.toString());
        boolean isAvalable = check result.isAvalable;

        if !isAvalable {
            certificateRequest.requestStatus = FAILED;
        }

        certificateRequest.requestStatus = PENDING;
        return certificateRequest;
    }
}
