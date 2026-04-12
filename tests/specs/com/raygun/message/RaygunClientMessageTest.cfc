component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.clientMessage = new com.raygun.message.RaygunClientMessage();
    }

    function run() {
        describe( "RaygunClientMessage", function() {
            it( "should initialize without error", function() {
                expect( variables.clientMessage ).toBeInstanceOf( "com.raygun.message.RaygunClientMessage" );
            } );

            it( "should return struct with name, version, and clientUrl keys", function() {
                var result = variables.clientMessage.build();

                expect( result ).toBeStruct();
                expect( result ).toHaveKey( "name" );
                expect( result ).toHaveKey( "version" );
                expect( result ).toHaveKey( "clientUrl" );
            } );

            it( "should have name matching RaygunConfig client name", function() {
                var result = variables.clientMessage.build();

                expect( result.name ).toBe( com.raygun.environment.RaygunConfig::getRaygunClientName() );
            } );

            it( "should have version matching RaygunConfig client version", function() {
                var result = variables.clientMessage.build();

                expect( result.version ).toBe( com.raygun.environment.RaygunConfig::getRaygunClientVersion() );
            } );

            it( "should have clientUrl matching RaygunConfig client URL", function() {
                var result = variables.clientMessage.build();

                expect( result.clientUrl ).toBe( com.raygun.environment.RaygunConfig::getRaygunClientUrl() );
            } );
        } );
    }

}
