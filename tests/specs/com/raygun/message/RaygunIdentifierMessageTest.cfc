component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.userIdentifier = new com.raygun.message.RaygunIdentifierMessage();
    }

    function run() {
        describe( "RaygunIdentifierMessage", function() {
            it( "should initialize with default values", function() {
                expect( variables.userIdentifier.getIdentifier() ).toBeEmpty();
                expect( variables.userIdentifier.getIsAnonymous() ).toBeTrue();
                expect( variables.userIdentifier.getEmail() ).toBeEmpty();
                expect( variables.userIdentifier.getFullName() ).toBeEmpty();
                expect( variables.userIdentifier.getFirstName() ).toBeEmpty();
                expect( variables.userIdentifier.getUUID() ).toBeEmpty();
            } );

            it( "should set and get identifier", function() {
                variables.userIdentifier.setIdentifier( "test-id-123" );
                expect( variables.userIdentifier.getIdentifier() ).toBe( "test-id-123" );
            } );

            it( "should set and get anonymous flag", function() {
                variables.userIdentifier.setIsAnonymous( true );
                expect( variables.userIdentifier.getIsAnonymous() ).toBeTrue();
            } );

            it( "should set and get email", function() {
                variables.userIdentifier.setEmail( "test@example.com" );
                expect( variables.userIdentifier.getEmail() ).toBe( "test@example.com" );
            } );

            it( "should set and get full name", function() {
                variables.userIdentifier.setFullName( "John Doe" );
                expect( variables.userIdentifier.getFullName() ).toBe( "John Doe" );
            } );

            it( "should set and get first name", function() {
                variables.userIdentifier.setFirstName( "John" );
                expect( variables.userIdentifier.getFirstName() ).toBe( "John" );
            } );

            it( "should set and get UUID", function() {
                var testUUID = createUUID();
                variables.userIdentifier.setUUID( testUUID );
                expect( variables.userIdentifier.getUUID() ).toBe( testUUID );
            } );

            it( "should build complete identifier message", function() {
                var testIdentifier = new com.raygun.message.RaygunIdentifierMessage();
                testIdentifier.setIdentifier( "user123" );
                testIdentifier.setIsAnonymous( false );
                testIdentifier.setEmail( "john@example.com" );
                testIdentifier.setFullName( "John Doe" );
                testIdentifier.setFirstName( "John" );
                testIdentifier.setUUID( createUUID() );

                var message = testIdentifier.build();

                expect( message ).toBeStruct();
                expect( message.identifier ).toBe( "user123" );
                expect( message.isAnonymous ).toBeFalse();
                expect( message.email ).toBe( "john@example.com" );
                expect( message.fullName ).toBe( "John Doe" );
                expect( message.firstName ).toBe( "John" );
                expect( message.uuid ).toBeString();
            } );
        } );
    }

}
