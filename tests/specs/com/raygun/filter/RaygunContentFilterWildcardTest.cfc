component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunContentFilter wildcard filtering", function() {
            it( "should filter keys matching a prefix wildcard pattern", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "pass*",
                        replacement : "[FILTERED]"
                    }
                ] );

                var messageData = {
                    password   : "secret",
                    passphrase : "also-secret",
                    passCode   : "1234",
                    username   : "visible",
                    details    : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.password ).toBe( "[FILTERED]" );
                expect( result.passphrase ).toBe( "[FILTERED]" );
                expect( result.passCode ).toBe( "[FILTERED]" );
                expect( result.username ).toBe( "visible" );
            } );

            it( "should filter keys matching a suffix wildcard pattern", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "*token",
                        replacement : "[FILTERED]"
                    }
                ] );

                var messageData = {
                    authToken    : "abc123",
                    refreshToken : "def456",
                    username     : "visible",
                    details      : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.authToken ).toBe( "[FILTERED]" );
                expect( result.refreshToken ).toBe( "[FILTERED]" );
                expect( result.username ).toBe( "visible" );
            } );

            it( "should filter keys matching a contains wildcard pattern", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "*secret*",
                        replacement : "[FILTERED]"
                    }
                ] );

                var messageData = {
                    mySecretKey  : "hidden",
                    secretValue  : "hidden",
                    topSecret123 : "hidden",
                    publicData   : "visible",
                    details      : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.mySecretKey ).toBe( "[FILTERED]" );
                expect( result.secretValue ).toBe( "[FILTERED]" );
                expect( result.topSecret123 ).toBe( "[FILTERED]" );
                expect( result.publicData ).toBe( "visible" );
            } );

            it( "should filter nested struct keys with wildcards", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "api*",
                        replacement : "[FILTERED]"
                    }
                ] );

                var messageData = {
                    nested : {
                        apiKey    : "hidden",
                        apiSecret : "hidden",
                        name      : "visible"
                    },
                    details : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.nested.apiKey ).toBe( "[FILTERED]" );
                expect( result.nested.apiSecret ).toBe( "[FILTERED]" );
                expect( result.nested.name ).toBe( "visible" );
            } );

            it( "should match wildcards case-insensitively", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "credit*",
                        replacement : "[FILTERED]"
                    }
                ] );

                var messageData = {
                    creditCard  : "4111",
                    CreditScore : "750",
                    CREDITLIMIT : "5000",
                    details     : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.creditCard ).toBe( "[FILTERED]" );
                expect( result.CreditScore ).toBe( "[FILTERED]" );
                expect( result.CREDITLIMIT ).toBe( "[FILTERED]" );
            } );

            it( "should not filter complex values with wildcards", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "pass*",
                        replacement : "[FILTERED]"
                    }
                ] );

                var complexValue = { nested : "data" };
                var messageData  = {
                    password : complexValue,
                    details  : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.password ).toBe( complexValue );
            } );

            it( "should filter wildcard patterns in rawData JSON", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "api*",
                        replacement : "[FILTERED]"
                    }
                ] );

                var jsonData = {
                    apiKey    : "secret-key",
                    apiSecret : "secret-value",
                    username  : "test"
                };

                var messageData = { details : { request : { rawData : serializeJSON( jsonData ) } } };

                var result        = filter.apply( messageData );
                var processedJson = deserializeJSON( result.details.request.rawData );
                expect( processedJson.apiKey ).toBe( "[FILTERED]" );
                expect( processedJson.apiSecret ).toBe( "[FILTERED]" );
                expect( processedJson.username ).toBe( "test" );
            } );

            it( "should still support exact match filters alongside wildcards", function() {
                var filter = new com.raygun.filter.RaygunContentFilter( [
                    {
                        filter      : "password",
                        replacement : "[exact]"
                    },
                    {
                        filter      : "api*",
                        replacement : "[wildcard]"
                    }
                ] );

                var messageData = {
                    password : "secret",
                    apiKey   : "key123",
                    details  : { request : {} }
                };

                var result = filter.apply( messageData );
                expect( result.password ).toBe( "[exact]" );
                expect( result.apiKey ).toBe( "[wildcard]" );
            } );
        } );
    }

}
