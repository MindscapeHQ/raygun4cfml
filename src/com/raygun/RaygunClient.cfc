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
    property name="breadcrumbs"       type="array";
    property name="onBeforeSend"     type="any";
    property name="ignoreExceptions" type="array";

    public RaygunClient function init(
        required string apiKey,
        RaygunContentFilter contentFilter,
        string appVersion,
        RaygunSettings settings,
        any onBeforeSend,
        array ignoreExceptions
    ) {
        setApiKey( arguments.apiKey );
        setBreadcrumbs( [] );
        setIgnoreExceptions( arguments.keyExists( "ignoreExceptions" ) ? arguments.ignoreExceptions : [] );

        if ( arguments.keyExists( "onBeforeSend" ) && isCustomFunction( arguments.onBeforeSend ) ) {
            setOnBeforeSend( arguments.onBeforeSend );
        }

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
        // Skip ignored exception types (case-insensitive match)
        if ( isStruct( arguments.issueData ) && arguments.issueData.keyExists( "type" ) && isExceptionIgnored( arguments.issueData.type ) ) {
            return "";
        }

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

        // Allow the onBeforeSend callback to inspect, mutate, or cancel the payload
        try {
            var callback = getOnBeforeSend();
            if ( !isNull( callback ) && isCustomFunction( callback ) ) {
                var callbackResult = callback( deserializeJSON( payload ) );

                if ( isBoolean( callbackResult ) && !callbackResult ) {
                    return "";
                }

                if ( isStruct( callbackResult ) ) {
                    payload = serializeJSON( callbackResult )
                        .trim()
                        .replaceNoCase( "//{", "{" )
                        .replaceNoCase( "//[", "[" );
                }
            }
        } catch ( any e ) {
            // No callback set or callback errored — proceed with original payload
        }

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
        if ( !isNull( getSettings() ) && isInstanceOf( getSettings(), "RaygunSettings" ) ) {
            var raygunSettings = getSettings().getSettings();
        }

        var messageContent = new message.RaygunMessage( settings = raygunSettings ).build( augmentedIssueData );

        // Apply content filtering if configured to protect sensitive data
        if (
            !isNull( getContentFilter() ) && isInstanceOf(
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
        var postResult   = "";
        var apiEndpoint  = resolveApiEndpoint();
        var httpTimeout  = resolveHttpTimeout();
        var maxRetries   = resolveMaxRetries();
        var retryDelay   = resolveRetryDelay();

        if ( arguments.sendAsync ) {
            // Use threading for async transmission to prevent blocking the main request
            thread action="run" name="sendAsyncToRaygunThread_#createUUID()#" apiKey=getApiKey() payload=arguments.jsonData endpoint=apiEndpoint httpTimeoutSecs=httpTimeout retries=maxRetries retryDelaySecs=retryDelay {
                var attempts = 0;
                var success  = false;

                while ( !success && attempts <= attributes.retries ) {
                    try {
                        if ( attempts > 0 ) {
                            sleep( attributes.retryDelaySecs * 1000 );
                        }

                        cfhttp(
                            url     = attributes.endpoint,
                            method  = "post",
                            charset = "utf-8",
                            timeout = attributes.httpTimeoutSecs
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

                        success = true;
                    } catch ( any e ) {
                        attempts++;

                        if ( attempts > attributes.retries ) {
                            writeLog(
                                text = "Error when trying to send to Raygun async (after #attempts# attempt(s)): #serializeJSON( e )#",
                                type = "error",
                                file = com.raygun.environment.RaygunConfig::getLogFileName()
                            );
                        }
                    }
                }
            }
        } else {
            // Synchronous transmission with retry support
            var attempts = 0;

            while ( attempts <= maxRetries ) {
                try {
                    if ( attempts > 0 ) {
                        sleep( retryDelay * 1000 );
                    }

                    cfhttp(
                        url     = apiEndpoint,
                        method  = "post",
                        charset = "utf-8",
                        timeout = httpTimeout,
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

                    return postResult;
                } catch ( any e ) {
                    attempts++;

                    if ( attempts > maxRetries ) {
                        rethrow;
                    }
                }
            }
        }

        return postResult;
    }

    /**
     * Resolves the API endpoint from settings, falling back to the default.
     */
    private string function resolveApiEndpoint() {
        if ( !isNull( getSettings() ) && isInstanceOf( getSettings(), "RaygunSettings" ) ) {
            return getSettings().getApiEndpoint();
        }
        return com.raygun.environment.RaygunConfig::getApiEndpoint();
    }

    /**
     * Resolves the HTTP timeout from settings, falling back to the default.
     */
    private numeric function resolveHttpTimeout() {
        if ( !isNull( getSettings() ) && isInstanceOf( getSettings(), "RaygunSettings" ) ) {
            return getSettings().getHttpTimeout();
        }
        return com.raygun.environment.RaygunConfig::getDefaultHttpTimeout();
    }

    /**
     * Resolves the max retry count from settings, falling back to the default.
     */
    private numeric function resolveMaxRetries() {
        if ( !isNull( getSettings() ) && isInstanceOf( getSettings(), "RaygunSettings" ) ) {
            return getSettings().getMaxRetries();
        }
        return com.raygun.environment.RaygunConfig::getDefaultMaxRetries();
    }

    /**
     * Resolves the retry delay from settings, falling back to the default.
     */
    private numeric function resolveRetryDelay() {
        if ( !isNull( getSettings() ) && isInstanceOf( getSettings(), "RaygunSettings" ) ) {
            return getSettings().getRetryDelay();
        }
        return com.raygun.environment.RaygunConfig::getDefaultRetryDelay();
    }

    /**
     * Checks whether the given exception type is in the ignore list.
     */
    private boolean function isExceptionIgnored( required string exceptionType ) {
        for ( var ignored in getIgnoreExceptions() ) {
            if ( compareNoCase( arguments.exceptionType, ignored ) == 0 ) {
                return true;
            }
        }
        return false;
    }

}
