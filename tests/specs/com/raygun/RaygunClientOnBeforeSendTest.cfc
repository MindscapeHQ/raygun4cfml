component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunClient onBeforeSend hook", function() {

            it( "should accept onBeforeSend closure in constructor", function() {
                var cb = function( payload ) {
                    return payload;
                };

                var rgClient = new com.raygun.RaygunClient(
                    apiKey       = "test-key",
                    onBeforeSend = cb
                );

                expect( rgClient ).toBeInstanceOf( "com.raygun.RaygunClient" );
            } );

            it( "should work without onBeforeSend set", function() {
                var rgClient = new com.raygun.RaygunClient( apiKey = "test-key" );
                expect( rgClient ).toBeInstanceOf( "com.raygun.RaygunClient" );
            } );

            it( "should allow setting onBeforeSend via setter", function() {
                var rgClient = new com.raygun.RaygunClient( apiKey = "test-key" );
                var cb = function( payload ) {
                    return payload;
                };
                rgClient.setOnBeforeSend( cb );
                expect( isCustomFunction( rgClient.getOnBeforeSend() ) ).toBeTrue();
            } );

            it( "should pass the payload struct to the callback", function() {
                var capturedPayload = {};
                var cb = function( payload ) {
                    capturedPayload = payload;
                    return false;
                };

                var rgClient = new com.raygun.RaygunClient(
                    apiKey       = "test-key",
                    onBeforeSend = cb
                );

                rgClient.send( issueData = {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( capturedPayload ).toBeStruct();
                expect( capturedPayload ).toHaveKey( "occurredOn" );
                expect( capturedPayload ).toHaveKey( "details" );
                expect( capturedPayload.details ).toHaveKey( "error" );
                expect( capturedPayload.details.error.message ).toBe( "Test error" );
            } );

            it( "should cancel sending when callback returns false", function() {
                var cb = function( payload ) {
                    return false;
                };

                var rgClient = new com.raygun.RaygunClient(
                    apiKey       = "test-key",
                    onBeforeSend = cb
                );

                var result = rgClient.send( issueData = {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( result ).toBe( "" );
            } );

            it( "should allow mutating the payload via the callback", function() {
                var cb = function( payload ) {
                    payload[ "details" ][ "tags" ] = [ "injected-tag" ];
                    return payload;
                };

                var rgClient = new com.raygun.RaygunClient(
                    apiKey       = "test-key",
                    onBeforeSend = cb
                );

                expect( function() {
                    rgClient.send(
                        issueData = {
                            message    : "Test error",
                            type       : "Application",
                            stacktrace : "",
                            tagcontext : []
                        },
                        sendAsync = true
                    );
                } ).notToThrow();
            } );

            it( "should proceed with original payload when callback throws", function() {
                var cb = function( payload ) {
                    throw( "Callback error" );
                };

                var rgClient = new com.raygun.RaygunClient(
                    apiKey       = "test-key",
                    onBeforeSend = cb
                );

                expect( function() {
                    rgClient.send(
                        issueData = {
                            message    : "Test error",
                            type       : "Application",
                            stacktrace : "",
                            tagcontext : []
                        },
                        sendAsync = true
                    );
                } ).notToThrow();
            } );

        } );
    }

}
