/**
 * Application component that extends base Application.cfc to add error handling
 * capabilities using Raygun error tracking service
 */
component extends="samples.Application" {

    public void function onRequestStart() {
        super.onRequestStart();
    }

    /**
     * Handles uncaught exceptions by sending detailed error reports to Raygun
     *
     * This error handler captures unhandled exceptions and sends them to Raygun
     * along with user session data, request parameters and user identification
     * to help with debugging and error tracking in production environments.
     */
    public void function onError(
        required any exception,
        required string eventName
    ) {
        // Prepare custom user data to provide context about the user's session
        // and what they were doing when the error occurred
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

        // Tag the error to help with filtering and categorization in Raygun dashboard
        var tags = [ "onError", "unfiltered", "unhandled exception" ];

        // Include user identification details to track which users are experiencing errors
        var userIdentifier = new com.raygun.message.RaygunIdentifierMessage()
            .setIdentifier( "test@test.com" )
            .setIsAnonymous( false )
            .setUuid( "47e432fff11" )
            .setFirstName( "Test" )
            .setFullName( "Tester" );

        // Initialize Raygun client with API credentials and version tracking
        var raygun = new com.raygun.RaygunClient(
            apiKey     = variables.RAYGUNAPIKEY,
            appVersion = "4.3.6"
        );

        // Send the error report to Raygun with all contextual information
        var result = raygun.send(
            issueData      = arguments.exception,
            userCustomData = customUserData,
            tags           = tags,
            user           = userIdentifier
        );
    }

}
