component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunRequestMessage form field truncation", function() {

            it( "should have a form field max length constant of 256", function() {
                expect( com.raygun.environment.RaygunConfig::getFormFieldMaxLength() ).toBe( 256 );
            } );

            it( "should return a struct with form key from build()", function() {
                var msg    = new com.raygun.message.RaygunRequestMessage();
                var result = msg.build();

                expect( result ).toHaveKey( "form" );
                expect( result.form ).toBeStruct();
            } );

        } );
    }

}
