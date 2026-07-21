component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.exceptionMessage = new com.raygun.message.RaygunExceptionMessage();
    }

    function run() {
        describe( "RaygunExceptionMessage bugs", function() {
            describe( "BUG: stackTrace should be populated from tagcontext when stacktrace string is empty", function() {
                it( "should populate stackTrace from tagcontext when stacktrace is empty", function() {
                    // BUG: When a CFML exception has an empty stacktrace string but a populated
                    // tagcontext array, the Raygun API field error.stackTrace ends up as an empty
                    // array. The Raygun API requires at least one stack frame with lineNumber.
                    // tagcontext data is only placed under data.tagContext, not error.stackTrace.
                    var testException = {
                        message    : "Variable TEST is undefined",
                        type       : "Expression",
                        stacktrace : "",
                        tagcontext : [
                            {
                                id             : "cfscript",
                                template       : "/app/views/index.cfm",
                                line           : 42,
                                codePrintPlain : "writeOutput(test);"
                            },
                            {
                                id             : "cfscript",
                                template       : "/app/Application.cfc",
                                line           : 15,
                                codePrintPlain : "include 'views/index.cfm';"
                            }
                        ]
                    };

                    var result = variables.exceptionMessage.build( testException );

                    // error.stackTrace should NOT be empty when tagcontext has data
                    expect( result.stackTrace ).toBeArray();
                    expect( result.stackTrace ).notToBeEmpty(
                        "stackTrace should be populated from tagcontext when stacktrace string is empty"
                    );

                    // Each frame should have lineNumber as required by the Raygun API
                    if ( result.stackTrace.len() ) {
                        expect( result.stackTrace[ 1 ] ).toHaveKey( "lineNumber" );
                        expect( result.stackTrace[ 1 ] ).toHaveKey( "fileName" );
                    }
                } );
            } );

            describe( "BUG: case-sensitive type check for database errors", function() {
                // NOTE: On Lucee, == is case-insensitive so these pass by accident.
                // On ACF, == is case-sensitive so these would fail without a fix.
                // The underlying code should use compareNoCase() for cross-engine safety.

                it( "should detect database errors regardless of type casing", function() {
                    var dbException = {
                        message    : "SQL error",
                        type       : "Database",
                        stacktrace : "",
                        tagcontext : [],
                        sql        : "SELECT * FROM users",
                        queryError : "Table not found"
                    };

                    var result = variables.exceptionMessage.build( dbException );

                    expect( result.data ).toHaveKey(
                        "database",
                        "Database errors should be detected regardless of type casing"
                    );
                    expect( result.data.database.sql ).toBe( "SELECT * FROM users" );
                } );

                it( "should detect database errors with uppercase type", function() {
                    var dbException = {
                        message    : "SQL error",
                        type       : "DATABASE",
                        stacktrace : "",
                        tagcontext : [],
                        sql        : "SELECT 1",
                        queryError : "Syntax error"
                    };

                    var result = variables.exceptionMessage.build( dbException );

                    expect( result.data ).toHaveKey(
                        "database",
                        "DATABASE (uppercase) should be detected as a database error"
                    );
                } );
            } );
        } );
    }

}
