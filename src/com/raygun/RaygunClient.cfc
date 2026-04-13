/**
 * Primary client for sending error reports to Raygun's API.
 * Handles payload construction, filtering, and transmission while managing
 * cross-platform compatibility between different CFML engines.
 */
component accessors="true" {

    // Core configuration properties required for Raygun integration
    property name="apiKey"        type="string"              default="";
    property name="contentFilter" type="RaygunContentFilter";
    property name="appVersion"    type="string"              default="";
    property name="settings"      type="RaygunSettings";
    property name="breadcrumbs"   type="array";

    public RaygunClient function init(
        required string apiKey,
        RaygunContentFilter contentFilter,
        string appVersion,
        RaygunSettings settings
    ) {
        setApiKey( arguments.apiKey );
        setBreadcrumbs( [] );

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
     * Records a breadcrumb to provide context about events leading up to an error.
     * Breadcrumbs are included in subsequent error reports sent via send() or sendAsync().
     *
     * @message Descriptive text for this breadcrumb
     * @level Severity level: debug, info, warning, or error (default: info)
     * @type Breadcrumb type (default: manual)
     * @category Optional grouping category
     * @className Optional source class name
     * @methodName Optional source method name
     * @lineNumber Optional source line number
     * @customData Optional struct of additional key-value data
     */
    public RaygunClient function recordBreadcrumb(
        required string message,
        string level      = "info",
        string type       = "manual",
        string category   = "",
        string className  = "",
        string methodName = "",
        numeric lineNumber,
        struct customData
    ) {
        var crumbArgs = {
            "message"    : arguments.message,
            "level"      : arguments.level,
            "type"       : arguments.type,
            "category"   : arguments.category,
            "className"  : arguments.className,
            "methodName" : arguments.methodName
        };

        if ( arguments.keyExists( "lineNumber" ) ) {
            crumbArgs[ "lineNumber" ] = arguments.lineNumber;
        }

        if ( arguments.keyExists( "customData" ) ) {
            crumbArgs[ "customData" ] = arguments.customData;
        }

        getBreadcrumbs().append(
            new message.RaygunBreadcrumbMessage( argumentCollection = crumbArgs )
        );

        return this;
    }

    /**
     * Clears all recorded breadcrumbs.
     */
    public RaygunClient function clearBreadcrumbs() {
        setBreadcrumbs( [] );
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

        if ( getBreadcrumbs().len() ) {
            augmentedIssueData[ "breadcrumbs" ] = getBreadcrumbs();
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

        return enforceMaxPayloadSize( jsonData );
    }

    /**
     * Ensures the JSON payload does not exceed the Raygun API's maximum size limit.
     * If oversized, strips expendable fields and re-serializes. As a last resort,
     * truncates the raw JSON string.
     */
    private string function enforceMaxPayloadSize( required string jsonData ) {
        var maxSize = com.raygun.environment.RaygunConfig::getMaxPayloadSize();

        if ( len( arguments.jsonData ) <= maxSize ) {
            return arguments.jsonData;
        }

        var payload = deserializeJSON( arguments.jsonData );

        // Strip expendable fields in order of decreasing size/decreasing importance
        var expendablePaths = [
            [ "details", "request", "rawData" ],
            [ "details", "userCustomData" ],
            [ "details", "request", "data" ],
            [ "details", "request", "headers" ],
            [ "details", "request", "form" ]
        ];

        for ( var path in expendablePaths ) {
            var target = payload;
            var found  = true;

            for ( var i = 1; i < path.len(); i++ ) {
                if ( isStruct( target ) && target.keyExists( path[ i ] ) ) {
                    target = target[ path[ i ] ];
                } else {
                    found = false;
                    break;
                }
            }

            if ( found && isStruct( target ) && target.keyExists( path[ path.len() ] ) ) {
                target[ path[ path.len() ] ] = "[truncated]";

                var reduced = serializeJSON( payload )
                    .trim()
                    .replaceNoCase( "//{", "{" )
                    .replaceNoCase( "//[", "[" );

                if ( len( reduced ) <= maxSize ) {
                    return reduced;
                }
            }
        }

        return left( arguments.jsonData, maxSize );
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
                        url     = com.raygun.environment.RaygunConfig::getApiEndpoint(),
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
                        file = com.raygun.environment.RaygunConfig::getLogFileName()
                    );
                }
            }
        } else {
            // Synchronous transmission allows error handling by the caller
            cfhttp(
                url     = com.raygun.environment.RaygunConfig::getApiEndpoint(),
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
