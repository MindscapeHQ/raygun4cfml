/**
 * Represents the core message details for a Raygun error report.
 * This component aggregates all the different aspects of an error report including
 * exception details, request information, client data, environment specifics, and response data.
 */
component accessors="true" {

    property name="settings" type="struct";

    property name="raygunExceptionMessage"   type="RaygunExceptionMessage";
    property name="raygunRequestMessage"     type="RaygunRequestMessage";
    property name="raygunClientMessage"      type="RaygunClientMessage";
    property name="raygunEnvironmentMessage" type="RaygunEnvironmentMessage";
    property name="raygunResponseMessage"    type="RaygunResponseMessage";

    public RaygunMessageDetails function init(
        RaygunExceptionMessage raygunExceptionMessage,
        RaygunRequestMessage raygunRequestMessage,
        RaygunClientMessage raygunClientMessage,
        RaygunEnvironmentMessage raygunEnvironmentMessage,
        RaygunResponseMessage raygunResponseMessage,
        struct settings = {}
    ) {
        setSettings( arguments.settings );
        setRaygunExceptionMessage( !isNull(arguments.raygunExceptionMessage) && isInstanceOf(arguments.raygunExceptionMessage, "RaygunExceptionMessage") ? arguments.raygunExceptionMessage : new RaygunExceptionMessage() );
        setRaygunRequestMessage( !isNull(arguments.raygunRequestMessage) && isInstanceOf(arguments.raygunRequestMessage, "RaygunRequestMessage") ? arguments.raygunRequestMessage : new RaygunRequestMessage() );
        setRaygunClientMessage( !isNull(arguments.raygunClientMessage) && isInstanceOf(arguments.raygunClientMessage, "RaygunClientMessage") ? arguments.raygunClientMessage : new RaygunClientMessage() );
        setRaygunEnvironmentMessage( !isNull(arguments.raygunEnvironmentMessage) && isInstanceOf(arguments.raygunEnvironmentMessage, "RaygunEnvironmentMessage") ? arguments.raygunEnvironmentMessage : new RaygunEnvironmentMessage() );
        setRaygunResponseMessage( !isNull(arguments.raygunResponseMessage) && isInstanceOf(arguments.raygunResponseMessage, "RaygunResponseMessage") ? arguments.raygunResponseMessage : new RaygunResponseMessage( settings = getSettings() ) );
    
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
        required struct issueData
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
        returnContent[ "request" ]     = raygunRequestMessage.build( getSettings() );
        returnContent[ "client" ]      = raygunClientMessage.build();
        returnContent[ "environment" ] = raygunEnvironmentMessage.build();
        // writeDump(raygunResponseMessage);
        // writeDump(getSettings());
        returnContent[ "response" ]    = raygunResponseMessage.build( arguments.issueData);

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
