component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.settings = new com.raygun.environment.RaygunSettings();
    }

    function run() {
        describe( "RaygunSettings", function() {
            it( "should initialize with default raw data max length", function() {
                expect( variables.settings.getRawDataMaxLength() ).toBe( com.raygun.environment.RaygunConfig::getRawDataMaxLengthDefault() );
            } );

            it( "should initialize with custom raw data max length", function() {
                var customLength = 8192;
                var settings     = new com.raygun.environment.RaygunSettings( customLength );
                expect( settings.getRawDataMaxLength() ).toBe( customLength );
            } );

            it( "should initialize with default status code", function() {
                expect( variables.settings.getStatusCode() ).toBe( 500 );
            } );

            it( "should initialize with custom status code", function() {
                var settings = new com.raygun.environment.RaygunSettings( statusCode = 503 );
                expect( settings.getStatusCode() ).toBe( 503 );
            } );

            it( "should return settings as struct", function() {
                var result = variables.settings.getSettings();
                expect( result ).toBeStruct();
                expect( result ).toHaveKey( "rawDataMaxLength" );
                expect( result.rawDataMaxLength ).toBe( variables.settings.getRawDataMaxLength() );
                expect( result ).toHaveKey( "statusCode" );
                expect( result.statusCode ).toBe( 500 );
                expect( result ).toHaveKey( "apiEndpoint" );
            } );

            it( "should initialize with default API endpoint", function() {
                expect( variables.settings.getApiEndpoint() ).toBe(
                    com.raygun.environment.RaygunConfig::getApiEndpoint()
                );
            } );

            it( "should initialize with custom API endpoint", function() {
                var settings = new com.raygun.environment.RaygunSettings(
                    apiEndpoint = "https://custom.example.com/entries"
                );
                expect( settings.getApiEndpoint() ).toBe( "https://custom.example.com/entries" );
            } );

            it( "should include API endpoint in settings struct", function() {
                var settings = new com.raygun.environment.RaygunSettings(
                    apiEndpoint = "https://custom.example.com/entries"
                );
                var result = settings.getSettings();
                expect( result.apiEndpoint ).toBe( "https://custom.example.com/entries" );
            } );

            it( "should initialize with default HTTP timeout", function() {
                expect( variables.settings.getHttpTimeout() ).toBe( 10 );
            } );

            it( "should initialize with custom HTTP timeout", function() {
                var settings = new com.raygun.environment.RaygunSettings( httpTimeout = 30 );
                expect( settings.getHttpTimeout() ).toBe( 30 );
            } );

            it( "should include HTTP timeout in settings struct", function() {
                var result = variables.settings.getSettings();
                expect( result ).toHaveKey( "httpTimeout" );
                expect( result.httpTimeout ).toBe( 10 );
            } );
        } );
    }

}
