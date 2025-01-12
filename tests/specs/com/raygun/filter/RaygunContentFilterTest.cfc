component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.filter = new com.raygun.filter.RaygunContentFilter();
    }

    function run() {
        describe( "RaygunContentFilter", function() {
            it( "should initialize with empty filter array when no filters provided", function() {
                expect( variables.filter.getFilter() ).toBeArray();
                expect( variables.filter.getFilter() ).toHaveLength( 0 );
            } );

            it( "should initialize with provided filters", function() {
                var testFilters = [
                    {
                        filter      : "password",
                        replacement : "[filtered]"
                    },
                    {
                        filter      : "apiKey",
                        replacement : "[filtered]"
                    }
                ];
                var filter = new com.raygun.filter.RaygunContentFilter( testFilters );

                expect( filter.getFilter() ).toBe( testFilters );
            } );

            describe( "apply() tests", function() {
                beforeEach( function() {
                    variables.filter = new com.raygun.filter.RaygunContentFilter( [
                        {
                            filter      : "password",
                            replacement : "[filtered]"
                        },
                        {
                            filter      : "creditCard",
                            replacement : "[filtered]"
                        }
                    ] );
                } );

                it( "should filter simple values in message data", function() {
                    var messageData = {
                        someKey  : "someValue",
                        password : "secret123",
                        details  : { request : {} }
                    };

                    var result = variables.filter.apply( messageData );
                    expect( result.password ).toBe( "[filtered]" );
                    expect( result.someKey ).toBe( "someValue" );
                } );

                it( "should filter nested JSON in rawData", function() {
                    var jsonData = {
                        username : "test",
                        password : "secret123"
                    };

                    var messageData = { details : { request : { rawData : serializeJSON( jsonData ) } } };

                    var result        = variables.filter.apply( messageData );
                    var processedJson = deserializeJSON( result.details.request.rawData );

                    expect( processedJson.password ).toBe( "[filtered]" );
                    expect( processedJson.username ).toBe( "test" );
                } );

                it( "should handle non-JSON rawData without error", function() {
                    var messageData = { details : { request : { rawData : "plain text data" } } };

                    var result = variables.filter.apply( messageData );
                    expect( result.details.request.rawData ).toBe( "plain text data" );
                } );

                it( "should not modify complex values when filtering", function() {
                    var complexValue = { key : "value" };
                    var messageData  = {
                        password : complexValue,
                        details  : { request : {} }
                    };

                    var result = variables.filter.apply( messageData );
                    expect( result.password ).toBe( complexValue );
                } );
            } );
        } );
    }

}
