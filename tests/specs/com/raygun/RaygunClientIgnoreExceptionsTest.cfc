component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunClient ignoreExceptions", function() {
            it( "should initialize with empty ignore list by default", function() {
                var rgClient = new com.raygun.RaygunClient( apiKey = "test-key" );
                expect( rgClient.getIgnoreExceptions() ).toBeArray();
                expect( rgClient.getIgnoreExceptions() ).toHaveLength( 0 );
            } );

            it( "should accept ignoreExceptions in constructor", function() {
                var rgClient = new com.raygun.RaygunClient(
                    apiKey           = "test-key",
                    ignoreExceptions = [ "MissingInclude", "AbortException" ]
                );
                expect( rgClient.getIgnoreExceptions() ).toHaveLength( 2 );
            } );

            it( "should skip sending when exception type is in ignore list", function() {
                var rgClient = new com.raygun.RaygunClient(
                    apiKey           = "test-key",
                    ignoreExceptions = [ "MissingInclude" ]
                );

                var result = rgClient.send(
                    issueData = {
                        message    : "File not found",
                        type       : "MissingInclude",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( result ).toBe( "" );
            } );

            it( "should match exception types case-insensitively", function() {
                var rgClient = new com.raygun.RaygunClient(
                    apiKey           = "test-key",
                    ignoreExceptions = [ "missinginclude" ]
                );

                var result = rgClient.send(
                    issueData = {
                        message    : "File not found",
                        type       : "MissingInclude",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( result ).toBe( "" );
            } );

            it( "should not skip sending for non-ignored exception types", function() {
                var rgClient = new com.raygun.RaygunClient(
                    apiKey           = "test-key",
                    ignoreExceptions = [ "MissingInclude" ]
                );

                // Application type is not in the ignore list, so send() should
                // proceed to build payload (will fail at HTTP but not return "")
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

            it( "should allow updating ignore list via setter", function() {
                var rgClient = new com.raygun.RaygunClient( apiKey = "test-key" );
                rgClient.setIgnoreExceptions( [ "CustomError" ] );
                expect( rgClient.getIgnoreExceptions() ).toHaveLength( 1 );

                var result = rgClient.send(
                    issueData = {
                        message    : "Custom",
                        type       : "CustomError",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( result ).toBe( "" );
            } );

            it( "should support multiple ignored types", function() {
                var rgClient = new com.raygun.RaygunClient(
                    apiKey           = "test-key",
                    ignoreExceptions = [ "MissingInclude", "AbortException", "LockTimeout" ]
                );

                var result1 = rgClient.send(
                    issueData = {
                        message    : "a",
                        type       : "MissingInclude",
                        stacktrace : "",
                        tagcontext : []
                    }
                );
                var result2 = rgClient.send(
                    issueData = {
                        message    : "b",
                        type       : "AbortException",
                        stacktrace : "",
                        tagcontext : []
                    }
                );
                var result3 = rgClient.send(
                    issueData = {
                        message    : "c",
                        type       : "LockTimeout",
                        stacktrace : "",
                        tagcontext : []
                    }
                );

                expect( result1 ).toBe( "" );
                expect( result2 ).toBe( "" );
                expect( result3 ).toBe( "" );
            } );
        } );
    }

}
