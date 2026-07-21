/**
 * Integration tests that validate the patterns used in /samples.
 * Each test mirrors a sample directory, using onBeforeSend to capture
 * and assert on the payload without sending to Raygun.
 */
component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "Sample pattern: try-catch (samples/try-catch)", function() {
            it( "should capture a division-by-zero error with correct payload structure", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    appVersion   = "3.4.5",
                    onBeforeSend = cb
                );

                try {
                    var a = 14;
                    var b = 0;
                    var c = a / b;
                } catch ( any e ) {
                    raygun.send( e );
                }

                expect( capturedPayload ).toHaveKey( "occurredOn" );
                expect( capturedPayload ).toHaveKey( "details" );
                expect( capturedPayload.details ).toHaveKey( "error" );
                expect( capturedPayload.details ).toHaveKey( "version" );
                expect( capturedPayload.details.version ).toBe( "3.4.5" );
                expect( capturedPayload.details ).toHaveKey( "client" );
                expect( capturedPayload.details ).toHaveKey( "environment" );
                expect( capturedPayload.details ).toHaveKey( "request" );
                expect( capturedPayload.details ).toHaveKey( "response" );
                expect( capturedPayload.details.error ).toHaveKey( "message" );
                expect( capturedPayload.details.error ).toHaveKey( "className" );
            } );
        } );

        describe( "Sample pattern: app-cfc-no-filter (samples/app-cfc-no-filter)", function() {
            it( "should include custom user data in the payload", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

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

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    appVersion   = "4.3.6",
                    onBeforeSend = cb
                );

                raygun.send(
                    issueData = {
                        message    : "variable [TEST5678] doesn't exist",
                        type       : "Expression",
                        stacktrace : "",
                        tagcontext : []
                    },
                    userCustomData = customUserData,
                    tags           = [ "onError", "unfiltered", "unhandled exception" ]
                );

                expect( capturedPayload.details ).toHaveKey( "userCustomData" );
                expect( capturedPayload.details.userCustomData ).toHaveKey( "session" );
                expect( capturedPayload.details.userCustomData.session ).toHaveKey( "memberID" );
                expect( capturedPayload.details.userCustomData.session.memberID ).toBe( "5747854" );
            } );

            it( "should include tags in the payload", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    onBeforeSend = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    },
                    tags = [ "onError", "unfiltered", "unhandled exception" ]
                );

                expect( capturedPayload.details ).toHaveKey( "tags" );
                expect( capturedPayload.details.tags ).toBeArray();
                expect( capturedPayload.details.tags ).toHaveLength( 3 );
                expect( capturedPayload.details.tags ).toInclude( "onError" );
                expect( capturedPayload.details.tags ).toInclude( "unfiltered" );
            } );

            it( "should include user identification in the payload", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var userIdentifier = new com.raygun.message.RaygunIdentifierMessage()
                    .setIdentifier( "test@test.com" )
                    .setIsAnonymous( false )
                    .setUuid( "47e432fff11" )
                    .setFirstName( "Test" )
                    .setFullName( "Tester" );

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    onBeforeSend = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    },
                    user = userIdentifier
                );

                expect( capturedPayload.details ).toHaveKey( "user" );
                expect( capturedPayload.details.user ).toHaveKey( "identifier" );
                expect( capturedPayload.details.user.identifier ).toBe( "test@test.com" );
                expect( capturedPayload.details.user.isAnonymous ).toBeFalse();
                expect( capturedPayload.details.user.firstName ).toBe( "Test" );
                expect( capturedPayload.details.user.fullName ).toBe( "Tester" );
                expect( capturedPayload.details.user.uuid ).toBe( "47e432fff11" );
            } );
        } );

        describe( "Sample pattern: app-cfc-content-filter (samples/app-cfc-content-filter)", function() {
            it( "should filter sensitive fields from the payload", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

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
                var contentFilter = new com.raygun.filter.RaygunContentFilter( filterRaw );

                var customUserData = new com.raygun.user.RaygunUserCustomData( {
                    "password"   : "secret123",
                    "creditcard" : "4111-1111-1111-1111",
                    "safeField"  : "visible"
                } );

                var raygun = new com.raygun.RaygunClient(
                    apiKey        = "sample-test-key",
                    appVersion    = "4.3.6",
                    contentFilter = contentFilter,
                    onBeforeSend  = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    },
                    userCustomData = customUserData
                );

                expect( capturedPayload.details ).toHaveKey( "userCustomData" );
                expect( capturedPayload.details.userCustomData.password ).toBe( "__password__" );
                expect( capturedPayload.details.userCustomData.creditcard ).toBe( "__ccnumber__" );
                expect( capturedPayload.details.userCustomData.safeField ).toBe( "visible" );
            } );

            it( "should filter with wildcard patterns", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var contentFilter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "pass*",
                        replacement : "[FILTERED]"
                    },
                    {
                        filter      : "*token",
                        replacement : "[FILTERED]"
                    }
                ] );

                var customUserData = new com.raygun.user.RaygunUserCustomData( {
                    "password"     : "secret123",
                    "passphrase"   : "myPhrase",
                    "accessToken"  : "abc-xyz",
                    "refreshtoken" : "tok-123",
                    "username"     : "visible"
                } );

                var raygun = new com.raygun.RaygunClient(
                    apiKey        = "sample-test-key",
                    contentFilter = contentFilter,
                    onBeforeSend  = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    },
                    userCustomData = customUserData
                );

                expect( capturedPayload.details.userCustomData.password ).toBe( "[FILTERED]" );
                expect( capturedPayload.details.userCustomData.passphrase ).toBe( "[FILTERED]" );
                expect( capturedPayload.details.userCustomData.accessToken ).toBe( "[FILTERED]" );
                expect( capturedPayload.details.userCustomData.refreshtoken ).toBe( "[FILTERED]" );
                expect( capturedPayload.details.userCustomData.username ).toBe( "visible" );
            } );
        } );

        describe( "Sample pattern: app-cfc-settings (samples/app-cfc-settings)", function() {
            it( "should use custom settings for status code", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var settings = new com.raygun.environment.RaygunSettings(
                    rawDataMaxLength = 10000,
                    statusCode       = 418
                );

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    appVersion   = "4.3.6",
                    settings     = settings,
                    onBeforeSend = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( capturedPayload.details ).toHaveKey( "response" );
                expect( capturedPayload.details.response ).toHaveKey( "statusCode" );
                expect( capturedPayload.details.response.statusCode ).toBe( 418 );
            } );

            it( "should use custom settings for retry and timeout", function() {
                var settings = new com.raygun.environment.RaygunSettings(
                    httpTimeout = 30,
                    maxRetries  = 3,
                    retryDelay  = 2
                );

                expect( settings.getHttpTimeout() ).toBe( 30 );
                expect( settings.getMaxRetries() ).toBe( 3 );
                expect( settings.getRetryDelay() ).toBe( 2 );
            } );

            it( "should auto-set 404 status for MissingInclude exceptions", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    onBeforeSend = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Page not found",
                        type       : "MissingInclude",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( capturedPayload.details.response.statusCode ).toBe( 404 );
            } );
        } );

        describe( "Sample pattern: breadcrumbs (README example)", function() {
            it( "should include breadcrumbs in the payload", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    onBeforeSend = cb
                );

                raygun.recordBreadcrumb( message = "User logged in" );
                raygun.recordBreadcrumb(
                    message    = "Query executed",
                    level      = "debug",
                    category   = "database",
                    className  = "UserDAO",
                    methodName = "findById",
                    lineNumber = 42,
                    customData = { "sql" : "SELECT * FROM users WHERE id = ?" }
                );
                raygun.recordBreadcrumb(
                    message = "Page rendered",
                    level   = "info"
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( capturedPayload.details ).toHaveKey( "breadcrumbs" );
                expect( capturedPayload.details.breadcrumbs ).toBeArray();
                expect( capturedPayload.details.breadcrumbs ).toHaveLength( 3 );

                var crumb1 = capturedPayload.details.breadcrumbs[ 1 ];
                expect( crumb1.message ).toBe( "User logged in" );
                expect( crumb1.level ).toBe( "info" );

                var crumb2 = capturedPayload.details.breadcrumbs[ 2 ];
                expect( crumb2.message ).toBe( "Query executed" );
                expect( crumb2.level ).toBe( "debug" );
                expect( crumb2.category ).toBe( "database" );
                expect( crumb2.className ).toBe( "UserDAO" );
                expect( crumb2.methodName ).toBe( "findById" );
                expect( crumb2.lineNumber ).toBe( 42 );
                expect( crumb2 ).toHaveKey( "customData" );
                expect( crumb2.customData ).toHaveKey( "sql" );

                var crumb3 = capturedPayload.details.breadcrumbs[ 3 ];
                expect( crumb3.message ).toBe( "Page rendered" );
            } );
        } );

        describe( "Sample pattern: ignore exceptions (README example)", function() {
            it( "should skip ignored exception types", function() {
                var callbackInvoked = false;
                var cb              = function( payload ) {
                    callbackInvoked = true;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey           = "sample-test-key",
                    ignoreExceptions = [ "MissingInclude", "AbortException" ],
                    onBeforeSend     = cb
                );

                var result = raygun.send(
                    issueData = {
                        message    : "File not found",
                        type       : "MissingInclude",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( result ).toBe( "" );
                expect( callbackInvoked ).toBeFalse();
            } );

            it( "should send non-ignored exception types normally", function() {
                var callbackInvoked = false;
                var cb              = function( payload ) {
                    callbackInvoked = true;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey           = "sample-test-key",
                    ignoreExceptions = [ "MissingInclude" ],
                    onBeforeSend     = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Something broke",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( callbackInvoked ).toBeTrue();
            } );
        } );

        describe( "Sample pattern: full onError (README full example)", function() {
            it( "should produce a complete payload with all features combined", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var customData = new com.raygun.user.RaygunUserCustomData();
                customData.add( "sessionID", "abc-123" );
                customData.add( "currentAction", "checkout" );

                var tags = [ "onError", "production", "unhandled exception" ];

                var userIdentifier = new com.raygun.message.RaygunIdentifierMessage()
                    .setIdentifier( "user@example.com" )
                    .setIsAnonymous( false )
                    .setFullName( "Jane Smith" );

                var contentFilter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "pass*",
                        replacement : "[FILTERED]"
                    },
                    {
                        filter      : "creditCard",
                        replacement : "[FILTERED]"
                    }
                ] );

                var settings = new com.raygun.environment.RaygunSettings(
                    rawDataMaxLength = 10000,
                    httpTimeout      = 15,
                    maxRetries       = 3
                );

                var raygun = new com.raygun.RaygunClient(
                    apiKey           = "sample-test-key",
                    appVersion       = "1.0.0",
                    contentFilter    = contentFilter,
                    settings         = settings,
                    ignoreExceptions = [ "AbortException" ],
                    onBeforeSend     = cb
                );

                raygun.recordBreadcrumb(
                    message = "Error handler triggered",
                    level   = "error"
                );

                raygun.send(
                    issueData = {
                        message    : "Null pointer exception",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    },
                    userCustomData = customData,
                    tags           = tags,
                    user           = userIdentifier
                );

                expect( capturedPayload ).toHaveKey( "occurredOn" );
                expect( capturedPayload ).toHaveKey( "details" );

                var details = capturedPayload.details;

                expect( details ).toHaveKey( "error" );
                expect( details.error.message ).toBe( "Null pointer exception" );

                expect( details ).toHaveKey( "version" );
                expect( details.version ).toBe( "1.0.0" );

                expect( details ).toHaveKey( "tags" );
                expect( details.tags ).toHaveLength( 3 );
                expect( details.tags ).toInclude( "production" );

                expect( details ).toHaveKey( "user" );
                expect( details.user.identifier ).toBe( "user@example.com" );
                expect( details.user.fullName ).toBe( "Jane Smith" );

                expect( details ).toHaveKey( "userCustomData" );
                expect( details.userCustomData ).toHaveKey( "sessionID" );

                expect( details ).toHaveKey( "breadcrumbs" );
                expect( details.breadcrumbs ).toHaveLength( 1 );
                expect( details.breadcrumbs[ 1 ].message ).toBe( "Error handler triggered" );
                expect( details.breadcrumbs[ 1 ].level ).toBe( "error" );

                expect( details ).toHaveKey( "response" );
                expect( details ).toHaveKey( "client" );
                expect( details ).toHaveKey( "environment" );
                expect( details ).toHaveKey( "request" );
            } );
        } );

        describe( "Sample pattern: grouping key", function() {
            it( "should include a custom grouping key in the payload", function() {
                var capturedPayload = {};
                var cb              = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var raygun = new com.raygun.RaygunClient(
                    apiKey       = "sample-test-key",
                    onBeforeSend = cb
                );

                raygun.send(
                    issueData = {
                        message    : "Test error",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    },
                    groupingKey = "my-custom-grouping-key"
                );

                expect( capturedPayload.details ).toHaveKey( "groupingKey" );
                expect( capturedPayload.details.groupingKey ).toBe( "my-custom-grouping-key" );
            } );
        } );
    }

}
