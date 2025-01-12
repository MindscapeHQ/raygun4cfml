/**
 * Test suite for RaygunUserCustomData component which handles custom user data validation and building.
 * Custom data must be a struct to maintain consistency with Raygun's API expectations and
 * to ensure proper JSON serialization when sending error reports.
 */
component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunUserCustomData", () => {
            beforeEach( () => {
                variables.raygunUserCustomData = new com.raygun.user.RaygunUserCustomData();
            } );

            // Verifies that the component is correctly instantiated
            it( "should be a component", () => {
                expect( raygunUserCustomData ).toBeComponent();
            } );

            // Arrays are rejected because Raygun's API expects a flat key-value structure for custom data
            it( "should fail if incorrect data type array is provided", () => {
                expect( () => raygunUserCustomData.setUserCustomData( [ { "test" : "test" } ] ).build() ).toThrow();
            } );

            // Strings are rejected as they cannot represent the key-value pairs needed for custom data
            it( "should fail if incorrect data type string is provided", () => {
                expect( () => raygunUserCustomData.setUserCustomData( "My Data" ).build() ).toThrow();
            } );

            // Structs are the correct format as they match Raygun's API requirements
            it( "should not fail if correct data type struct is provided", () => {
                expect( () => raygunUserCustomData.setUserCustomData( { "test" : "test" } ).build() ).notToThrow();
            } );

            // Verifies that custom data is preserved exactly as provided
            it( "should return the correct data", () => {
                expect( raygunUserCustomData.setUserCustomData( { "test" : "test" } ).build() ).toBe( { "test" : "test" } );
            } );

            // Default state returns empty struct to maintain consistent return type
            it( "should create an empty struct on .build() without data", () => {
                expect( raygunUserCustomData.build() ).toBe( {} );
            } );

            // Ensures the component initializes with an empty custom data structure
            it( "should initialize with empty custom data", function() {
                expect( variables.raygunUserCustomData.getUserCustomData() ).toBeStruct();
                expect( variables.raygunUserCustomData.getUserCustomData() ).toBeEmpty();
            } );

            // Tests adding and retrieving a single key-value pair in custom data
            it( "should add and retrieve single data item", function() {
                variables.raygunUserCustomData.add( "testKey", "testValue" );

                var data = variables.raygunUserCustomData.getUserCustomData();
                expect( data.testKey ).toBe( "testValue" );
            } );

            // Tests adding and retrieving multiple key-value pairs in custom data
            it( "should add and retrieve multiple data items", function() {
                variables.raygunUserCustomData.add( "key1", "value1" );
                variables.raygunUserCustomData.add( "key2", 123 );
                variables.raygunUserCustomData.add( "key3", true );

                var data = variables.raygunUserCustomData.getUserCustomData();
                expect( data.key1 ).toBe( "value1" );
                expect( data.key2 ).toBe( 123 );
                expect( data.key3 ).toBeTrue();
            } );

            // Tests handling of complex data types like arrays and structs
            it( "should handle complex data types", function() {
                var arrayData  = [ 1, 2, 3 ];
                var structData = { a : 1, b : 2 };

                variables.raygunUserCustomData.add( "arrayKey", arrayData );
                variables.raygunUserCustomData.add( "structKey", structData );

                var data = variables.raygunUserCustomData.getUserCustomData();
                expect( data.arrayKey ).toBe( arrayData );
                expect( data.structKey ).toBe( structData );
            } );

            // Tests that adding a new value with an existing key overrides the old value
            it( "should override existing keys", function() {
                variables.raygunUserCustomData.add( "testKey", "originalValue" );
                variables.raygunUserCustomData.add( "testKey", "newValue" );

                expect( variables.raygunUserCustomData.getUserCustomData().testKey ).toBe( "newValue" );
            } );

            // Verifies that the build function returns the correct custom data message
            it( "should build custom data message", function() {
                var testData = new com.raygun.user.RaygunUserCustomData();
                testData.add( "string", "value" );
                testData.add( "number", 42 );
                testData.add( "boolean", true );

                var message = testData.build();

                expect( message ).toBeStruct();
                expect( message.string ).toBe( "value" );
                expect( message.number ).toBe( 42 );
                expect( message.boolean ).toBeTrue();
            } );
        } );
    }

}
