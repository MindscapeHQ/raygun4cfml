component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunMessageDetails", function() {
            it( "should initialize without error", function() {
                var details = new com.raygun.message.RaygunMessageDetails();
                expect( details ).toBeInstanceOf( "com.raygun.message.RaygunMessageDetails" );
            } );

            it( "should build a complete payload struct from minimal issue data", function() {
                var details   = new com.raygun.message.RaygunMessageDetails();
                var issueData = {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                };

                var result = details.build( issueData );

                expect( result ).toBeStruct();
                expect( result ).toHaveKey( "error" );
                expect( result ).toHaveKey( "request" );
                expect( result ).toHaveKey( "client" );
                expect( result ).toHaveKey( "environment" );
                expect( result ).toHaveKey( "response" );
                expect( result ).toHaveKey( "machineName" );
                expect( result ).toHaveKey( "tags" );
            } );

            it( "should include version when appVersion is provided", function() {
                var details = new com.raygun.message.RaygunMessageDetails();
                var result  = details.build( {
                    message    : "Test",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : [],
                    appVersion : "1.2.3"
                } );

                expect( result ).toHaveKey( "version" );
                expect( result.version ).toBe( "1.2.3" );
            } );

            it( "should include groupingKey when provided", function() {
                var details = new com.raygun.message.RaygunMessageDetails();
                var result  = details.build( {
                    message     : "Test",
                    type        : "Application",
                    stacktrace  : "",
                    tagcontext  : [],
                    groupingKey : "my-group"
                } );

                expect( result ).toHaveKey( "groupingKey" );
                expect( result.groupingKey ).toBe( "my-group" );
            } );

            it( "should include tags when provided", function() {
                var details = new com.raygun.message.RaygunMessageDetails();
                var result  = details.build( {
                    message    : "Test",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : [],
                    tags       : [ "tag1", "tag2" ]
                } );

                expect( result.tags ).toBeArray();
                expect( result.tags ).toHaveLength( 2 );
            } );

            it( "should propagate settings to sub-components", function() {
                var details = new com.raygun.message.RaygunMessageDetails(
                    settings = {
                        "rawDataMaxLength" : 200,
                        "statusCode"       : 503
                    }
                );

                // Response should use the custom status code
                var result = details.build( {
                    message    : "Test",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( result.response.statusCode ).toBe( 503 );
            } );

            it( "should not throw when called in a non-web context", function() {
                var details = new com.raygun.message.RaygunMessageDetails();

                expect( function() {
                    details.build( {
                        message    : "Test",
                        type       : "Application",
                        stacktrace : "",
                        tagcontext : []
                    } );
                } ).notToThrow();
            } );
        } );
    }

}
