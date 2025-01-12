/**
 * Sample Application.cfc demonstrating Raygun integration with content filtering
 * Extends the base Application.cfc to add error reporting capabilities while
 * protecting sensitive data through content filtering
 */
component extends="samples.Application" {

    public void function onRequestStart() {
        super.onRequestStart();
    }

    /**
     * Global error handler that captures unhandled exceptions and reports them to Raygun
     * Demonstrates proper error reporting setup including:
     * - Custom user data to provide request context
     * - User identification for error tracking
     * - Content filtering to protect sensitive data
     * - Proper tag categorization for filtering in the dashboard
     */
    public void function onError(
        required any exception,
        required string eventName
    ) {
        // Capture relevant session and request data to provide context
        // Only include non-sensitive data that helps with debugging
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

        // Tags help categorize errors for easier filtering and analysis
        var tags = [ "onError", "filtered", "unhandled exception" ];

        // Track user identity to understand impact and affected users
        // In production, this should use real user data
        var userIdentifier = new com.raygun.message.RaygunIdentifierMessage()
            .setIdentifier( "test@test.com" )
            .setIsAnonymous( false )
            .setUuid( "47e432fff11" )
            .setFirstName( "Test" )
            .setFullName( "Tester" );

        // Configure content filtering to protect sensitive data
        // Password and credit card patterns will be replaced with safe placeholders
        var filterRaw = [
            {
                filter      : "password",
                replacement : "__password__"
            },
            {
                filter      : "creditcard",
                replacement : "__ccnumber__"
            }
        ];
        var contentFilter = new com.raygun.filter.RaygunContentFilter().setFilter( filterRaw );

        var raygun = new com.raygun.RaygunClient(
            apiKey        = variables.RAYGUNAPIKEY,
            appVersion    = "4.3.6",
            contentFilter = contentFilter
        );

        // Send the error report synchronously to ensure delivery
        // For high-traffic applications, consider using sendAsync() instead, depending on your application's requirements and if Raygun is already called in a thread in your application.
        var result = raygun.send(
            issueData      = arguments.exception,
            userCustomData = customUserData,
            tags           = tags,
            user           = userIdentifier
        );
    }

}
