component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.envMessage = new com.raygun.message.RaygunEnvironmentMessage();
    }

    function run() {
        describe( "RaygunEnvironmentMessage", function() {

            it( "should initialize without error", function() {
                expect( variables.envMessage ).toBeInstanceOf( "com.raygun.message.RaygunEnvironmentMessage" );
            } );

            it( "should return a struct from build()", function() {
                var result = variables.envMessage.build();
                expect( result ).toBeStruct();
            } );

            it( "should include architecture", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "architecture" );
                expect( result.architecture ).notToBeEmpty();
            } );

            it( "should include osVersion", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "osVersion" );
                expect( result.osVersion ).notToBeEmpty();
            } );

            it( "should include platform", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "platform" );
                expect( result.platform ).notToBeEmpty();
            } );

            it( "should include packageVersion with JVM info", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "packageVersion" );
                expect( result.packageVersion ).notToBeEmpty();
            } );

            it( "should include model with CFML engine info", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "model" );
                expect( result.model ).notToBeEmpty();
            } );

            it( "should include memory fields", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "availableVirtualMemory" );
                expect( result ).toHaveKey( "totalVirtualMemory" );
                expect( result ).toHaveKey( "availablePhysicalMemory" );
                expect( result ).toHaveKey( "totalPhysicalMemory" );
            } );

        } );
    }

}
