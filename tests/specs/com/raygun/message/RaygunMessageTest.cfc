component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunMessage", function() {

            it( "should initialize without error", function() {
                var msg = new com.raygun.message.RaygunMessage();
                expect( msg ).toBeInstanceOf( "com.raygun.message.RaygunMessage" );
            } );

            it( "should build a struct with occurredOn and details keys", function() {
                var msg    = new com.raygun.message.RaygunMessage();
                var result = msg.build( {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( result ).toBeStruct();
                expect( result ).toHaveKey( "occurredOn" );
                expect( result ).toHaveKey( "details" );
            } );

            it( "should produce an ISO8601 UTC timestamp in occurredOn", function() {
                var msg    = new com.raygun.message.RaygunMessage();
                var result = msg.build( {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( result.occurredOn ).toMatch( "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$" );
            } );

            it( "should propagate settings to RaygunMessageDetails", function() {
                var msg    = new com.raygun.message.RaygunMessage(
                    settings = { "statusCode" : 418 }
                );
                var result = msg.build( {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( result.details.response.statusCode ).toBe( 418 );
            } );

            it( "should include details with all expected sub-keys", function() {
                var msg    = new com.raygun.message.RaygunMessage();
                var result = msg.build( {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( result.details ).toHaveKey( "error" );
                expect( result.details ).toHaveKey( "request" );
                expect( result.details ).toHaveKey( "client" );
                expect( result.details ).toHaveKey( "environment" );
                expect( result.details ).toHaveKey( "response" );
            } );

        } );
    }

}
