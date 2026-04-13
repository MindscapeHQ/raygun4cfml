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
                expect( com.raygun.environment.RaygunConfig::getRaygunClientVersion() ).toBe( "3.0.0-rc.1" );
            } );

            it( "should provide client URL", function() {
                expect( com.raygun.environment.RaygunConfig::getRaygunClientUrl() ).toBe(
                    "https://github.com/MindscapeHQ/raygun4cfml"
                );
            } );

            it( "should provide default status code", function() {
                expect( com.raygun.environment.RaygunConfig::getDefaultStatusCode() ).toBe( 500 );
            } );

            it( "should provide API endpoint", function() {
                expect( com.raygun.environment.RaygunConfig::getApiEndpoint() ).toBe(
                    "https://api.raygun.com/entries"
                );
            } );

            it( "should provide log file name", function() {
                expect( com.raygun.environment.RaygunConfig::getLogFileName() ).toBe( "Raygun4CFML" );
            } );

            it( "should provide HTML content type", function() {
                expect( com.raygun.environment.RaygunConfig::getContentTypeHtml() ).toBe( "text/html" );
            } );

            it( "should provide form content type", function() {
                expect( com.raygun.environment.RaygunConfig::getContentTypeForm() ).toBe(
                    "application/x-www-form-urlencoded"
                );
            } );

            it( "should provide HTTP GET method", function() {
                expect( com.raygun.environment.RaygunConfig::getHttpMethodGet() ).toBe( "GET" );
            } );

            it( "should provide form field max length", function() {
                expect( com.raygun.environment.RaygunConfig::getFormFieldMaxLength() ).toBe( 256 );
            } );

            it( "should provide max payload size", function() {
                expect( com.raygun.environment.RaygunConfig::getMaxPayloadSize() ).toBe( 131072 );
            } );

            it( "should provide default HTTP timeout", function() {
                expect( com.raygun.environment.RaygunConfig::getDefaultHttpTimeout() ).toBe( 10 );
            } );

            it( "should provide default max retries", function() {
                expect( com.raygun.environment.RaygunConfig::getDefaultMaxRetries() ).toBe( 2 );
            } );

            it( "should provide default retry delay", function() {
                expect( com.raygun.environment.RaygunConfig::getDefaultRetryDelay() ).toBe( 1 );
            } );
        } );
    }

}
