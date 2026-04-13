component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunClient breadcrumbs", function() {

            beforeEach( function() {
                variables.rgClient = new com.raygun.RaygunClient( apiKey = "test-key" );
            } );

            it( "should initialize with empty breadcrumbs array", function() {
                expect( variables.rgClient.getBreadcrumbs() ).toBeArray();
                expect( variables.rgClient.getBreadcrumbs() ).toHaveLength( 0 );
            } );

            it( "should record a breadcrumb and return this for chaining", function() {
                var result = variables.rgClient.recordBreadcrumb( message = "User clicked submit" );
                expect( result ).toBeInstanceOf( "com.raygun.RaygunClient" );
                expect( variables.rgClient.getBreadcrumbs() ).toHaveLength( 1 );
            } );

            it( "should record multiple breadcrumbs", function() {
                variables.rgClient
                    .recordBreadcrumb( message = "Page loaded" )
                    .recordBreadcrumb( message = "Form submitted" )
                    .recordBreadcrumb( message = "API call made" );

                expect( variables.rgClient.getBreadcrumbs() ).toHaveLength( 3 );
            } );

            it( "should record breadcrumb with all optional fields", function() {
                variables.rgClient.recordBreadcrumb(
                    message    = "Query executed",
                    level      = "debug",
                    type       = "request",
                    category   = "database",
                    className  = "UserDAO",
                    methodName = "findAll",
                    lineNumber = 55,
                    customData = { "sql" : "SELECT *" }
                );

                var crumbs = variables.rgClient.getBreadcrumbs();
                expect( crumbs ).toHaveLength( 1 );

                var built = crumbs[ 1 ].build();
                expect( built.message ).toBe( "Query executed" );
                expect( built.level ).toBe( "debug" );
                expect( built.type ).toBe( "request" );
                expect( built.category ).toBe( "database" );
                expect( built.className ).toBe( "UserDAO" );
                expect( built.methodName ).toBe( "findAll" );
                expect( built.lineNumber ).toBe( 55 );
                expect( built.customData.sql ).toBe( "SELECT *" );
            } );

            it( "should clear all breadcrumbs", function() {
                variables.rgClient
                    .recordBreadcrumb( message = "first" )
                    .recordBreadcrumb( message = "second" );

                expect( variables.rgClient.getBreadcrumbs() ).toHaveLength( 2 );

                var result = variables.rgClient.clearBreadcrumbs();
                expect( result ).toBeInstanceOf( "com.raygun.RaygunClient" );
                expect( variables.rgClient.getBreadcrumbs() ).toHaveLength( 0 );
            } );

        } );

        describe( "RaygunMessageDetails breadcrumbs integration", function() {

            it( "should include breadcrumbs in payload when provided", function() {
                var crumbs = [
                    new com.raygun.message.RaygunBreadcrumbMessage( message = "Step 1" ),
                    new com.raygun.message.RaygunBreadcrumbMessage( message = "Step 2", level = "warning" )
                ];

                var details = new com.raygun.message.RaygunMessageDetails();
                var result  = details.build( {
                    message     : "Test error",
                    type        : "Application",
                    stacktrace  : "",
                    tagcontext  : [],
                    breadcrumbs : crumbs
                } );

                expect( result ).toHaveKey( "breadcrumbs" );
                expect( result.breadcrumbs ).toBeArray();
                expect( result.breadcrumbs ).toHaveLength( 2 );
                expect( result.breadcrumbs[ 1 ].message ).toBe( "Step 1" );
                expect( result.breadcrumbs[ 2 ].message ).toBe( "Step 2" );
                expect( result.breadcrumbs[ 2 ].level ).toBe( "warning" );
            } );

            it( "should not include breadcrumbs key when none provided", function() {
                var details = new com.raygun.message.RaygunMessageDetails();
                var result  = details.build( {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                } );

                expect( structKeyExists( result, "breadcrumbs" ) ).toBeFalse();
            } );

        } );
    }

}
