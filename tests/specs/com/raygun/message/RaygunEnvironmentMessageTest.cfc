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

            it( "should not throw when gathering memory metrics", function() {
                expect( function() {
                    variables.envMessage.build();
                } ).notToThrow();
            } );

            it( "should include processorCount as a positive number", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "processorCount" );
                expect( result.processorCount ).toBeGT( 0 );
            } );

            it( "should include locale as a non-empty string", function() {
                var result = variables.envMessage.build();
                expect( result ).toHaveKey( "locale" );
                expect( result.locale ).notToBeEmpty();
            } );

            it( "should not throw when gathering utcOffset", function() {
                expect( function() {
                    variables.envMessage.build();
                } ).notToThrow();
            } );

        } );
    }

}
