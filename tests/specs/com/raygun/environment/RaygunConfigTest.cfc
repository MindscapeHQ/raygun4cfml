component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunConfig", function() {
            it( "should provide default raw data max length", function() {
                expect( com.raygun.environment.RaygunConfig::getRawDataMaxLengthDefault() ).toBe(
                    com.raygun.environment.RaygunConfig::getRawDataMaxLengthDefault()
                );
            } );

            it( "should provide client name", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientName() ).toBe(
                    com.raygun.environment.RaygunConfig::getRaygunClientName()
                );
            } );

            it( "should provide client version", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientVersion() ).toBe(
                    com.raygun.environment.RaygunConfig::getRaygunClientVersion()
                );
            } );

            it( "should provide client URL", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientUrl() ).toBe(
                    com.raygun.environment.RaygunConfig::getRaygunClientUrl()
                );
            } );
        } );
    }

}
