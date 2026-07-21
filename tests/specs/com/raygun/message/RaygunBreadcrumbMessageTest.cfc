component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "RaygunBreadcrumbMessage", function() {
            it( "should initialize with required message", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "User clicked button" );
                expect( crumb.getMessage() ).toBe( "User clicked button" );
            } );

            it( "should default level to info", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "test" );
                expect( crumb.getLevel() ).toBe( "info" );
            } );

            it( "should default type to manual", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "test" );
                expect( crumb.getType() ).toBe( "manual" );
            } );

            it( "should set an ISO8601 UTC timestamp automatically", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "test" );
                expect( crumb.getTimestamp() ).toMatch( "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$" );
            } );

            it( "should accept all optional fields", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage(
                    message    = "Query executed",
                    level      = "debug",
                    type       = "request",
                    category   = "database",
                    className  = "UserService",
                    methodName = "findById",
                    lineNumber = 42,
                    customData = { "query" : "SELECT * FROM users" }
                );

                expect( crumb.getLevel() ).toBe( "debug" );
                expect( crumb.getType() ).toBe( "request" );
                expect( crumb.getCategory() ).toBe( "database" );
                expect( crumb.getClassName() ).toBe( "UserService" );
                expect( crumb.getMethodName() ).toBe( "findById" );
                expect( crumb.getLineNumber() ).toBe( 42 );
                expect( crumb.getCustomData() ).toHaveKey( "query" );
            } );

            it( "should validate level and default invalid levels to info", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "test", level = "critical" );
                expect( crumb.getLevel() ).toBe( "info" );
            } );

            it( "should accept all valid levels", function() {
                var levels = [ "debug", "info", "warning", "error" ];
                for ( var lvl in levels ) {
                    var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "test", level = lvl );
                    expect( crumb.getLevel() ).toBe( lvl );
                }
            } );

            it( "should handle case-insensitive level validation", function() {
                var crumb = new com.raygun.message.RaygunBreadcrumbMessage( message = "test", level = "WARNING" );
                expect( crumb.getLevel() ).toBe( "warning" );
            } );

            describe( "build()", function() {
                it( "should return a struct with required fields", function() {
                    var crumb  = new com.raygun.message.RaygunBreadcrumbMessage( message = "test" );
                    var result = crumb.build();

                    expect( result ).toBeStruct();
                    expect( result ).toHaveKey( "timestamp" );
                    expect( result ).toHaveKey( "level" );
                    expect( result ).toHaveKey( "type" );
                    expect( result ).toHaveKey( "message" );
                    expect( result ).toHaveKey( "category" );
                    expect( result ).toHaveKey( "className" );
                    expect( result ).toHaveKey( "methodName" );
                } );

                it( "should include lineNumber when set", function() {
                    var crumb  = new com.raygun.message.RaygunBreadcrumbMessage( message = "test", lineNumber = 99 );
                    var result = crumb.build();
                    expect( result ).toHaveKey( "lineNumber" );
                    expect( result.lineNumber ).toBe( 99 );
                } );

                it( "should exclude lineNumber when not set", function() {
                    var crumb  = new com.raygun.message.RaygunBreadcrumbMessage( message = "test" );
                    var result = crumb.build();
                    expect( structKeyExists( result, "lineNumber" ) ).toBeFalse();
                } );

                it( "should include customData when set", function() {
                    var crumb = new com.raygun.message.RaygunBreadcrumbMessage(
                        message    = "test",
                        customData = { "key" : "value" }
                    );
                    var result = crumb.build();
                    expect( result ).toHaveKey( "customData" );
                    expect( result.customData.key ).toBe( "value" );
                } );

                it( "should exclude customData when not set", function() {
                    var crumb  = new com.raygun.message.RaygunBreadcrumbMessage( message = "test" );
                    var result = crumb.build();
                    expect( structKeyExists( result, "customData" ) ).toBeFalse();
                } );
            } );
        } );
    }

}
