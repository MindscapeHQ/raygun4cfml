component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.exceptionMessage = new com.raygun.message.RaygunExceptionMessage();
    }

    function run() {
        describe( "RaygunExceptionMessage", function() {
            it( "should handle basic CFML exceptions", function() {
                var testException = {
                    message    : "Test error message",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : []
                };

                var result = variables.exceptionMessage.build( testException );

                expect( result.message ).toBe( "Test error message" );
                expect( result.className ).toBe( "Application" );
                expect( result.stackTrace ).toBeArray();
                expect( result.data.tagContext ).toBeArray();
            } );

            it( "should process nested errors", function() {
                var nestedException = {
                    message    : "Inner error",
                    type       : "Database",
                    stacktrace : "",
                    tagcontext : []
                };

                var testException = {
                    message    : "Outer error",
                    type       : "Application",
                    stacktrace : "",
                    tagcontext : [],
                    Cause      : nestedException
                };

                var result = variables.exceptionMessage.build( testException );

                expect( result.message ).toBe( "Outer error" );
                expect( result.innerError ).toBeStruct();
                expect( result.innerError.message ).toBe( "Inner error" );
            } );

            it( "should handle database errors with SQL details", function() {
                var dbException = {
                    message         : "Database error",
                    type            : "database",
                    stacktrace      : "",
                    tagcontext      : [],
                    detail          : "SQL error details",
                    sql             : "SELECT * FROM test",
                    queryError      : "Table not found",
                    SQLState        : "42S02",
                    nativeErrorCode : "1146"
                };

                var result = variables.exceptionMessage.build( dbException );

                expect( result.data.database.detail ).toBe( "SQL error details" );
                expect( result.data.database.sql ).toBe( "SELECT * FROM test" );
                expect( result.data.database.SQLState ).toBe( "42S02" );
                expect( result.data.database.nativeErrorCode ).toBe( "1146" );
            } );

            it( "should handle string-based stack traces", function() {
                var testException = {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "Something at com.example.Class.method(Class.java:123)",
                    tagcontext : []
                };

                var result = variables.exceptionMessage.build( testException );

                expect( result.stackTrace ).toBeArray();
                expect( result.stackTrace.len() ).toBeGT( 0 );
                if ( result.stackTrace.len() ) {
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "methodName" );
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "className" );
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "fileName" );
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "lineNumber" );
                }
            } );

            it( "should handle string-based stack traces starting with 'at'", function() {
                var testException = {
                    message    : "Test error",
                    type       : "Application",
                    stacktrace : "at com.example.Class.method(Class.java:123)",
                    tagcontext : []
                };

                var result = variables.exceptionMessage.build( testException );

                expect( result.stackTrace ).toBeArray();
                expect( result.stackTrace.len() ).toBeGT( 0 );
                if ( result.stackTrace.len() ) {
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "methodName" );
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "className" );
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "fileName" );
                    expect( result.stackTrace[ 1 ] ).toHaveKey( "lineNumber" );
                }
            } );
        } );
    }

}
