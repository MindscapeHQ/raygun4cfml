component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunConfig", function() {
            it( "should provide default raw data max length", function() {
                expect( com.raygun.environment.RaygunConfig::getRawDataMaxLengthDefault() ).toBe( 4096 );
            } );

            it( "should provide client name", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientName() ).toBe( "raygun4cfml" );
            } );

            it( "should provide client version", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientVersion() ).toBe( "2.1.0" );
            } );

            it( "should provide client URL", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientUrl() ).toBe(
                    "https://github.com/MindscapeHQ/raygun4cfml"
                );
            } );

            it( "should provide default status code", function() {
                expect( com.raygun.environment.RaygunConfig::getDefaultStatusCode() ).toBe( 500 );
            } );
        } );
    }

}
