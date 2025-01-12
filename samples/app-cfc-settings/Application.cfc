/**
 * Application.cfc extends the base Application component to add custom error handling
 * and logging capabilities using the Raygun error tracking service.
 */
component extends="samples.Application" {

    public void function onRequestStart() {
        super.onRequestStart();
    }

    /**
     * Custom error handler that captures unhandled exceptions and sends them to Raygun
     * for monitoring and debugging. Includes user session data and request parameters
     * to provide context for troubleshooting production issues.
     */
    public void function onError(
        required any exception,
        required string eventName
    ) {
        // Mock user session data and request parameters to provide context
        // about what the user was doing when the error occurred
        var customUserDataRaw = {
            "session" : {
                "memberID"        : "5747854",
                "memberFirstName" : "Kai"
            },
            "params" : {
                "currentAction"    : "IwasDoingThis",
                "justAnotherParam" : "test"
            }
        };
        var customUserData = new com.raygun.user.RaygunUserCustomData().setUserCustomData( customUserDataRaw );

        // Tags help categorize the error for easier filtering in Raygun dashboard
        var tags = [ "onError", "unfiltered", "unhandled exception" ];

        // Include user identity information to track errors by user
        var userIdentifier = new com.raygun.message.RaygunIdentifierMessage()
            .setIdentifier( "test@test.com" )
            .setIsAnonymous( false )
            .setUuid( "47e432fff11" )
            .setFirstName( "Test" )
            .setFullName( "Tester" );

        // Increase max payload size to ensure detailed error data is captured
        var settings = new com.raygun.environment.RaygunSettings().setRawDataMaxLength( 10000 );

        var raygun = new com.raygun.RaygunClient(
            apiKey     = variables.RAYGUNAPIKEY,
            appVersion = "4.3.6",
            settings   = settings
        );

        // Send the error details to Raygun for logging and analysis
        var result = raygun.send(
            issueData      = arguments.exception,
            userCustomData = customUserData,
            tags           = tags,
            user           = userIdentifier
        );
    }

}
