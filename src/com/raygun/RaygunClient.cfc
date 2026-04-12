/**
 * Primary client for sending error reports to Raygun's API.
 * Handles payload construction, filtering, and transmission while managing
 * cross-platform compatibility between different CFML engines.
 */
component accessors="true" {

    // Core configuration properties required for Raygun integration
    property name="apiKey"        type="string"              default="";
    property name="contentFilter" type="RaygunContentFilter" default="";
    property name="appVersion"    type="string"              default="";
    property name="settings"      type="RaygunSettings"      default="";

    public RaygunClient function init(
        required string apiKey,
        RaygunContentFilter contentFilter,
        string appVersion,
        RaygunSettings settings
    ) {
        setApiKey( arguments.apiKey );

        if ( arguments.keyExists( "contentFilter" ) ) {
            setContentFilter( arguments.contentFilter );
        }

        if ( arguments.keyExists( "appVersion" ) ) {
            setAppVersion( arguments.appVersion );
        }

        if ( arguments.keyExists( "settings" ) ) {
            setSettings( arguments.settings );
        }

        return this;
    }

    /**
     * Primary method for sending error reports to Raygun.
     * Supports both synchronous and asynchronous transmission to accommodate
     * different error handling requirements and performance needs.
     *
     * @issueData Core error information to be reported
     * @userCustomData Optional diagnostic data to provide additional context
     * @tags Optional categorization tags for filtering in Raygun's dashboard
     * @user Optional user identification for tracking affected users
     * @groupingKey Optional key to control how Raygun groups similar errors
     * @sendAsync Whether to send the report asynchronously to prevent blocking
     */
    public function send(
        required any issueData,
        RaygunUserCustomData userCustomData,
        array tags,
        RaygunIdentifierMessage user,
        string groupingKey,
        boolean sendAsync = false
    ) {
        var payloadArgs = { "issueData" : arguments.issueData };

        if ( arguments.keyExists( "userCustomData" ) ) {
            payloadArgs[ "userCustomData" ] = arguments.userCustomData;
        }

        if ( arguments.keyExists( "tags" ) && isArray( arguments.tags ) ) {
            payloadArgs[ "tags" ] = arguments.tags;
        }

        if ( arguments.keyExists( "user" ) ) {
            payloadArgs[ "user" ] = arguments.user;
        }

        if ( arguments.keyExists( "groupingKey" ) && arguments.groupingKey.len() ) {
            payloadArgs[ "groupingKey" ] = arguments.groupingKey;
        }

        var payload = buildPayload( argumentCollection = payloadArgs );

        if ( arguments.sendAsync ) {
            sendPayload( payload, arguments.sendAsync );
        } else {
            return sendPayload( payload, arguments.sendAsync );
        }
    }

    /**
     * Convenience method for asynchronous error reporting.
     * Wraps the main send() method to simplify async reporting scenarios.
     */
    public void function sendAsync(
        required any issueData,
        RaygunUserCustomData userCustomData,
        array tags,
        RaygunIdentifierMessage user,
        string groupingKey
    ) {
        arguments[ "sendAsync" ] = true;
        send( argumentCollection = arguments );
    }

    /**
     * Constructs the JSON payload for Raygun's API.
     * Handles data augmentation, validation, and cross-platform JSON compatibility issues.
     * Applies content filtering if configured to protect sensitive data.
     */
    private string function buildPayload(
        required any issueData,
        RaygunUserCustomData userCustomData,
        array tags,
        RaygunIdentifierMessage user,
        string groupingKey
    ) {
        var augmentedIssueData = {};
        augmentedIssueData.append( duplicate( arguments.issueData ) );

        // API key validation is critical as Raygun will reject requests without valid authentication
        if ( !getApiKey().len() ) {
            throw( "API key not set, cannot send message to Raygun" );
        }

        if ( getAppVersion().len() ) {
            augmentedIssueData[ "appVersion" ] = getAppVersion();
        }

        if ( arguments.keyExists( "userCustomData" ) ) {
            augmentedIssueData[ "userCustomData" ] = arguments.userCustomData;
        }

        if ( arguments.keyExists( "tags" ) && isArray( arguments.tags ) ) {
            augmentedIssueData[ "tags" ] = arguments.tags;
        }

        if ( arguments.keyExists( "user" ) ) {
            augmentedIssueData[ "user" ] = arguments.user;
        }

        if ( arguments.keyExists( "groupingKey" ) && arguments.groupingKey.len() ) {
            augmentedIssueData[ "groupingKey" ] = arguments.groupingKey;
        }

        var raygunSettings = {};
        // Only apply settings if they've been properly initialized
        if ( isInstanceOf( getSettings(), "RaygunSettings" ) ) {
            var raygunSettings = getSettings().getSettings();
        }

        var messageContent = new message.RaygunMessage( settings = raygunSettings ).build( augmentedIssueData );

        // Apply content filtering if configured to protect sensitive data
        if (
            isInstanceOf(
                getContentFilter(),
                "RaygunContentFilter"
            )
        ) {
            messageContent = getContentFilter().apply( messageContent );
        }

        var jsonData = messageContent.toJSON();

        // Handle ACF's JSON serialization quirks to ensure compatibility
        // Some ACF security configurations add prefixes to JSON output that Raygun won't accept
        jsonData = jsonData
            .trim()
            .replaceNoCase( "//{", "{" )
            .replaceNoCase( "//[", "[" );

        return jsonData;
    }

    /**
     * Handles the actual HTTP transmission to Raygun's API.
     * Supports both synchronous and asynchronous transmission patterns.
     * Includes error logging for async failures to aid debugging.
     */
    private any function sendPayload(
        required string jsonData,
        boolean sendAsync = false
    ) {
        var postResult = "";

        if ( arguments.sendAsync ) {
            // Use threading for async transmission to prevent blocking the main request
            thread action="run" name="sendAsyncToRaygunThread_#createUUID()#" apiKey=getApiKey() payload=arguments.jsonData {
                try {
                    cfhttp(
                        url     = "https://api.raygun.com/entries",
                        method  = "post",
                        charset = "utf-8"
                    ) {
                        cfhttpparam(
                            type  = "header",
                            name  = "Content-Type",
                            value = "application/json"
                        );
                        cfhttpparam(
                            type  = "header",
                            name  = "X-ApiKey",
                            value = "#attributes.apiKey#"
                        );
                        cfhttpparam(
                            type  = "body",
                            value = "#attributes.payload#"
                        );
                    }
                } catch ( any e ) {
                    // Log async failures since they can't be reported back to the caller
                    writeLog(
                        text = "Error when trying to send to Raygun async: #serializeJSON( e )#",
                        type = "error",
                        file = "Raygun4CFML"
                    );
                }
            }
        } else {
            // Synchronous transmission allows error handling by the caller
            cfhttp(
                url     = "https://api.raygun.com/entries",
                method  = "post",
                charset = "utf-8",
                result  = "postResult"
            ) {
                cfhttpparam(
                    type  = "header",
                    name  = "Content-Type",
                    value = "application/json"
                );
                cfhttpparam(
                    type  = "header",
                    name  = "X-ApiKey",
                    value = getApiKey()
                );
                cfhttpparam(
                    type  = "body",
                    value = "#arguments.jsonData#"
                );
            }
        }

        return postResult;
    }

}
