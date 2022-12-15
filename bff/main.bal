import ballerina/http;
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
    boolean requestCreated;
};

type IdCheckResponse record {
    boolean isAvailable;
};

service /gramaSevakaAPI on new http:Listener(9091) {
    resource function post certificateRequest(@http:Payload CertificateRequest certificateRequest) returns CertificateRequest|error {
        json|error result = check citizen_apiEp->getNicNic(certificateRequest.id);
        if result is error {
            return error("internal error occured - citizen API not working");
        }
        IdCheckResponse|error idCheckResult = result.ensureType(IdCheckResponse);
        if idCheckResult is error {
            return error("internal error occured");
        }
        boolean isAvalable = idCheckResult.isAvailable;
        if !isAvalable {
            return error("ID is not available");
        }

        certificateRequest.requestCreated = true;

        return certificateRequest;
    }
}
