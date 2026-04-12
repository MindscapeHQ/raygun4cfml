component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunRequestMessage", function() {

            describe( "BUG: settings propagation", function() {

                it( "should use custom rawDataMaxLength from settings passed at construction", function() {
                    // BUG: RaygunMessageDetails creates RaygunRequestMessage() without settings,
                    // so even if settings are passed later, rawDataMaxLength is never applied.
                    var customLength = 50;
                    var msg          = new com.raygun.message.RaygunRequestMessage(
                        settings = { "rawDataMaxLength" : customLength }
                    );

                    // The settings should be stored and accessible
                    expect( msg.getSettings() ).toHaveKey( "rawDataMaxLength" );
                    expect( msg.getSettings().rawDataMaxLength ).toBe( customLength );
                } );

                it( "should store settings so build() can use them internally", function() {
                    // BUG: RaygunMessageDetails.build() calls raygunRequestMessage.build( getSettings() )
                    // but RaygunRequestMessage.build() accepts NO arguments — settings are ignored.
                    // The fix should make build() use this.getSettings() internally.
                    var msg = new com.raygun.message.RaygunRequestMessage(
                        settings = { "rawDataMaxLength" : 100 }
                    );

                    // Settings should be stored and available for build() to use
                    expect( msg.getSettings() ).toBeStruct();
                    expect( msg.getSettings() ).toHaveKey( "rawDataMaxLength" );
                    expect( msg.getSettings().rawDataMaxLength ).toBe( 100 );

                    // build() should complete without error
                    var result = msg.build();
                    expect( result ).toBeStruct();
                } );

            } );

            describe( "BUG: settings propagation through RaygunMessageDetails", function() {

                it( "should pass settings to RaygunRequestMessage when created by RaygunMessageDetails", function() {
                    // BUG: RaygunMessageDetails.init() creates `new RaygunRequestMessage()` without settings
                    // on line 35, so settings never reach the request message builder.
                    var customSettings = { "rawDataMaxLength" : 100 };
                    var details        = new com.raygun.message.RaygunMessageDetails(
                        settings = customSettings
                    );

                    // The internal RaygunRequestMessage should have received the settings
                    var requestMsg = details.getRaygunRequestMessage();
                    expect( requestMsg.getSettings() ).toHaveKey( "rawDataMaxLength" );
                    expect( requestMsg.getSettings().rawDataMaxLength ).toBe( 100 );
                } );

            } );

        } );
    }

}
