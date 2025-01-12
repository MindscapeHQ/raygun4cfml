/**
 * Represents the core message details for a Raygun error report.
 * This component aggregates all the different aspects of an error report including
 * exception details, request information, client data, and environment specifics.
 */
component accessors="true" {

    property name="raygunExceptionMessage"   type="RaygunExceptionMessage";
    property name="raygunRequestMessage"     type="RaygunRequestMessage";
    property name="raygunClientMessage"      type="RaygunClientMessage";
    property name="raygunEnvironmentMessage" type="RaygunEnvironmentMessage";

    public RaygunMessageDetails function init(
        RaygunExceptionMessage raygunExceptionMessage     = new RaygunExceptionMessage(),
        RaygunRequestMessage raygunRequestMessage         = new RaygunRequestMessage(),
        RaygunClientMessage raygunClientMessage           = new RaygunClientMessage(),
        RaygunEnvironmentMessage raygunEnvironmentMessage = new RaygunEnvironmentMessage()
    ) {
        setRaygunExceptionMessage( arguments.raygunExceptionMessage );
        setRaygunRequestMessage( arguments.raygunRequestMessage );
        setRaygunClientMessage( arguments.raygunClientMessage );
        setRaygunEnvironmentMessage( arguments.raygunEnvironmentMessage );
        return this;
    }

    /**
     * Constructs the complete error report payload for Raygun.
     * This method aggregates all the different components of an error report into a single structure
     * that matches Raygun's API expectations.
     *
     * @issueData The core error data to be processed
     * @settings Optional configuration settings that may affect how the request data is processed
     */
    public struct function build(
        required struct issueData,
        struct settings = {}
    ) {
        var returnContent = {};

        // Grouping key allows for custom error grouping in Raygun's dashboard
        if ( arguments.issueData.keyExists( "groupingKey" ) && arguments.issueData.groupingKey.len() ) {
            returnContent[ "groupingKey" ] = arguments.issueData.groupingKey;
        }

        // Version tracking helps identify which release may have introduced an issue
        if ( arguments.issueData.keyExists( "appVersion" ) ) {
            returnContent[ "version" ] = arguments.issueData.appVersion;
        } else {
            returnContent[ "version" ] = javacast( "null", "" );
        }

        // Attempt to get the real IP address, fallback to SERVER_NAME if Java networking is unavailable
        try {
            returnContent[ "machineName" ] = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostAddress();
        } catch ( any e ) {
            returnContent[ "machineName" ] = CGI.SERVER_NAME;
        }

        // Build the core components of the error report
        returnContent[ "error" ]       = raygunExceptionMessage.build( arguments.issueData );
        returnContent[ "request" ]     = raygunRequestMessage.build( arguments.settings );
        returnContent[ "client" ]      = raygunClientMessage.build();
        returnContent[ "environment" ] = raygunEnvironmentMessage.build();

        // Include any custom data if provided through a builder object
        if ( arguments.issueData.keyExists( "userCustomData" ) && isObject( arguments.issueData.userCustomData ) ) {
            returnContent[ "userCustomData" ] = arguments.issueData.userCustomData.build();
        } else {
            returnContent[ "userCustomData" ] = javacast( "null", "" );
        }

        // Tags allow for additional categorization and filtering in Raygun's dashboard
        if ( arguments.issueData.keyExists( "tags" ) && isArray( arguments.issueData.tags ) ) {
            returnContent[ "tags" ] = arguments.issueData.tags;
        } else {
            returnContent[ "tags" ] = [];
        }

        // User information helps track who was affected by an error
        if ( arguments.issueData.keyExists( "user" ) && isObject( arguments.issueData.user ) ) {
            returnContent[ "user" ] = arguments.issueData.user.build();
        } else {
            returnContent[ "user" ] = javacast( "null", "" );
        }

        return returnContent;
    }

}
