component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunResponseMessage bugs", function() {
            describe( "BUG: case-sensitive MissingInclude check", function() {
                // NOTE: On Lucee, == is case-insensitive so these pass by accident.
                // On ACF, == is case-sensitive so these would fail without a fix.
                // The underlying code should use compareNoCase() for cross-engine safety.

                it( "should return 404 for missinginclude (lowercase)", function() {
                    var msg    = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 500 } );
                    var result = msg.build( { "type" : "missinginclude" } );

                    expect( result.statusCode ).toBe(
                        404,
                        "missinginclude (lowercase) should map to 404"
                    );
                } );

                it( "should return 404 for MISSINGINCLUDE (uppercase)", function() {
                    var msg    = new com.raygun.message.RaygunResponseMessage( { "statusCode" : 500 } );
                    var result = msg.build( { "type" : "MISSINGINCLUDE" } );

                    expect( result.statusCode ).toBe(
                        404,
                        "MISSINGINCLUDE (uppercase) should map to 404"
                    );
                } );
            } );
        } );
    }

}
