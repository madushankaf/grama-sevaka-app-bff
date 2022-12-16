import madushankaorg/citizen_api;
import ballerina/http;
import ballerina/log;

//import ballerina/lang.value;

configurable string citizenAPIClientSecret = "XikBPFD_gf5JiWC5KebGqXixM3sa";
configurable string citizenAPIClientId = "p2apR7ikIqT8elLivV6yeGOzWjQa";

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

type IdCheckRequest record {
    boolean isAvailable;
};

citizen_api:Client citizen_apiEp = check new (config = {
    auth: {
        clientId: citizenAPIClientId,
        clientSecret: citizenAPIClientSecret
    }
});

service /gramaSevakaAPI on new http:Listener(9091) {
    resource function post certificateRequest(@http:Payload CertificateRequest certificateRequest) returns CertificateRequest|error {
        json result = check citizen_apiEp->getNicNic(certificateRequest.id);
        IdCheckRequest idCheckRequst = check result.ensureType(IdCheckRequest);
        log:printInfo(result.toString());
        log:printInfo(idCheckRequst.toString());
        boolean isAvalable = idCheckRequst.isAvailable;
        if !isAvalable {
            certificateRequest.requestStatus = FAILED;
        }
        certificateRequest.requestStatus = PENDING;
        return certificateRequest;
    }
}
