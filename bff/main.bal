import madushankaorg/police_verification_api;
import madushankaorg/citizen_api;
import ballerina/http;
import ballerina/regex;
import ballerina/log;

//import ballerina/lang.value;

configurable string citizenAPIClientSecret = "";
configurable string citizenAPIClientId = "";

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

address_api:Client address_apiEp = check new (config = {
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

            string[] addressStrings = regex:split(certificateRequest.address, ",");
            if (addressStrings.length() != 3) {
                certificateRequest.requestStatus = FAILED;
                certificateRequest.message = "Address format is incorrect.";
                return certificateRequest;
            }
            json addressResult = check address_apiEp->getAddressVerificationAddress(5, 6);
            if addressResult is error {
                certificateRequest.requestStatus = FAILED;
                certificateRequest.message = "Address was not retrieved";
                return certificateRequest;
            }

            boolean addressAvailable = check addressResult.addressAvailable;

            if !addressAvailable {
                certificateRequest.requestStatus = FAILED;
                certificateRequest.message = "Address is invalid";
                return certificateRequest;
            }

            certificateRequest.requestStatus = PENDING;
        }
        return certificateRequest;
    }
}
