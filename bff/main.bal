import madushankaorg/police_verification_api;
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
    string message;
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

type PoliceRecordStatus record {
    boolean policeRecotdStatus;
};

citizen_api:Client citizen_apiEp = check new (config = {
    auth: {
        clientId: citizenAPIClientId,
        clientSecret: citizenAPIClientSecret
    }
});

police_verification_api:Client police_verification_apiEp = check new (config = {
    auth: {
        clientId: citizenAPIClientId,
        clientSecret: citizenAPIClientSecret
    }
});

service /gramaSevakaAPI on new http:Listener(9091) {
    resource function post certificateRequest(@http:Payload CertificateRequest certificateRequest) returns CertificateRequest|error {
        IdCheckRequest result = check citizen_apiEp->getNicNic(certificateRequest.id);
        log:printInfo(result.toString());
        boolean isAvalable = result.isAvailable;
        if !isAvalable {
            certificateRequest.requestStatus = FAILED;
            certificateRequest.message = " NIC is not available, please verify.";
            return certificateRequest;
        }
        else {
            json policeResult = check police_verification_apiEp->getPoliceverificationNic(certificateRequest.id);
            boolean areCriminalRecordsAvailable = check policeResult.policeRecotdStatus;
            if areCriminalRecordsAvailable
            {
                certificateRequest.requestStatus = FAILED;
                certificateRequest.message = " Police verification failed, please contact the nearesrt police station";
                return certificateRequest;
            }

            certificateRequest.requestStatus = PENDING;
        }
        return certificateRequest;
    }
}
