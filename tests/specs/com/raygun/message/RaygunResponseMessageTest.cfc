component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.responseMessage = new com.raygun.message.RaygunResponseMessage();
    }

    function run() {
        describe( "RaygunResponseMessage", function() {
            it( "should initialize without error", function() {
                expect( variables.responseMessage ).toBeInstanceOf( "com.raygun.message.RaygunResponseMessage" );
            } );

            it( "should return default 500 status code when no settings provided", function() {
                var errorData = { "type" : "Application" };
                var result    = variables.responseMessage.build( errorData );

                expect( result.statusCode ).toBe( 500 );
            } );

            it( "should return custom status code from settings", function() {
                var msg    = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 503 } );
                var result = msg.build( { "type" : "Application" } );

                expect( result.statusCode ).toBe( 503 );
            } );

            it( "should return 404 for MissingInclude error type", function() {
                var msg    = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 500 } );
                var result = msg.build( { "type" : "MissingInclude" } );

                expect( result.statusCode ).toBe( 404 );
            } );

            it( "should return proper statusDescription for known codes", function() {
                var msg200 = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 200 } );
                expect( msg200.build( { "type" : "Application" } ).statusDescription ).toBe( "OK" );

                var msg404 = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 404 } );
                expect( msg404.build( { "type" : "Application" } ).statusDescription ).toBe( "Not Found" );

                var msg500 = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 500 } );
                expect( msg500.build( { "type" : "Application" } ).statusDescription ).toBe( "Internal Server Error" );

                var msg418 = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 418 } );
                expect( msg418.build( { "type" : "Application" } ).statusDescription ).toBe( "I'm a teapot" );
            } );

            it( "should return empty statusDescription for unknown codes", function() {
                var msg    = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 999 } );
                var result = msg.build( { "type" : "Application" } );

                expect( result.statusDescription ).toBe( "" );
            } );

            it( "should use RaygunConfig default when settings has no statusCode key", function() {
                var msg    = new com.raygun.message.RaygunResponseMessage( {} );
                var result = msg.build( { "type" : "Application" } );

                expect( result.statusCode ).toBe( com.raygun.environment.RaygunConfig::getDefaultStatusCode() );
            } );
        } );
    }

}
