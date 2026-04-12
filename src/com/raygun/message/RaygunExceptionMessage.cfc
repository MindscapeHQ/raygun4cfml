/**
 * Handles exception message formatting for Raygun error reports.
 * Processes both CFML and Java exceptions, including stack traces,
 * to provide detailed error context in a Raygun-compatible format.
 */
component {

    public RaygunExceptionMessage function init() {
        return this;
    }

    /**
     * Transforms CFML/Java exception data into Raygun's expected format.
     * Handles nested errors, database-specific errors, and both CFML tag context
     * and Java stack traces to provide comprehensive error details.
     *
     * @issueData The raw exception data to process
     */
    public struct function build( required struct issueData ) {
        var returnContent  = {};
        var stackTraceData = [];

        var entryPoint = arguments.issueData;

        // Process nested errors recursively to maintain full error chain
        if ( entryPoint.keyExists( "Cause" ) ) {
            returnContent[ "innerError" ] = build( duplicate( entryPoint.Cause ) );
        }

        // Handle both array-based and string-based stack traces. Typically, CFML engines produce the latter.
        if ( isArray( entryPoint.stacktrace ) ) {
            stackTraceData = entryPoint.stacktrace;
        } else if ( isSimpleValue( entryPoint.stacktrace ) ) {
            stackTraceData = parseStackTrace( entryPoint.stacktrace );
        }

        // Parse CFML tag context into structured data (also stored under data.tagContext)
        var tagContextData = parseTagContext( entryPoint );

        // If Java stack trace is empty but CFML tag context is available, use tag context
        // to populate stackTrace. The Raygun API requires at least one stack frame with lineNumber.
        if ( !stackTraceData.len() && tagContextData.len() ) {
            stackTraceData = tagContextData;
        }

        returnContent[ "stackTrace" ] = stackTraceData;
        returnContent[ "message" ]    = entryPoint.message;
        returnContent[ "className" ]  = entryPoint.type.trim();

        returnContent[ "data" ][ "tagContext" ] = tagContextData;
        // Only include error code if it's meaningful (non-zero and non-empty). The zero case is very common in CFML engines and it's not clear what it means, but doesn't seem to be useful.
        returnContent[ "data" ][ "errorCode" ]  = (
            entryPoint.keyExists( "errorcode" ) && len( entryPoint.errorcode ) && entryPoint.errorcode != 0
        ) ? entryPoint.errorcode : "";
        returnContent[ "data" ][ "extendedInfo" ] = ( entryPoint.keyExists( "extendedinfo" ) && entryPoint.extendedinfo.len() ) ? entryPoint.extendedinfo : "";

        // Additional handling for database errors to capture SQL-specific details
        if ( entryPoint.type == "database" ) {
            if ( !returnContent[ "message" ].len() ) returnContent[ "message" ] = "SQL/DB issue";

            var databaseData                      = {};
            databaseData[ "detail" ]              = ( entryPoint.keyExists( "detail" ) && entryPoint.detail.len() ) ? entryPoint.detail : "";
            databaseData[ "sql" ]                 = ( entryPoint.keyExists( "sql" ) && entryPoint.sql.len() ) ? entryPoint.sql : "";
            databaseData[ "queryError" ]          = ( entryPoint.keyExists( "queryError" ) && entryPoint.queryError.len() ) ? entryPoint.queryError : "";
            databaseData[ "nativeErrorCode" ]     = ( entryPoint.keyExists( "nativeErrorCode" ) && len( entryPoint.nativeErrorCode ) ) ? entryPoint.nativeErrorCode : "";
            databaseData[ "SQLState" ]            = ( entryPoint.keyExists( "SQLState" ) && entryPoint.SQLState.len() ) ? entryPoint.SQLState : "";
            returnContent[ "data" ][ "database" ] = databaseData;
        }

        return returnContent;
    }

    /**
     * Processes CFML's tag context to provide file and line information.
     * Includes code snippets when available (Lucee/BoxLang only) to aid debugging.
     * Adobe ColdFusion doesn't provide code snippets due to engine limitations.
     *
     * @entryPoint The exception data containing tag context
     */
    private array function parseTagContext( required struct entryPoint ) {
        var tagContextData = [];

        if ( entryPoint.keyExists( "tagcontext" ) ) {
            for ( var j = 1; j <= entryPoint.tagcontext.len(); j++ ) {
                tagContextData[ j ] = {
                    "className"  : entryPoint.tagcontext[ j ][ "id" ].trim(),
                    "fileName"   : entryPoint.tagcontext[ j ][ "template" ].trim(),
                    "lineNumber" : trim( entryPoint.tagcontext[ j ][ "line" ] )
                };

                // Code snippets enhance debugging but are engine-dependent
                if ( com.raygun.tools.RaygunInternalTools::isLucee() || com.raygun.tools.RaygunInternalTools::isBoxlang() ) {
                    tagContextData[ j ][ "code" ] = chr( 13 ) & "      " & entryPoint.tagcontext[ j ][ "codePrintPlain" ].trim();
                }
            }
        }

        return tagContextData;
    }

    /**
     * Parses Java-style stack traces from string format into structured data.
     * Handles variations in stack trace format, including cases without line numbers.
     * Uses regex to reliably extract method, class, file and line information.
     *
     * @stacktrace The raw stack trace string to parse
     */
    private array function parseStackTrace( required string stacktrace ) {
        var stackTraceData  = [];
        var stackTraceLines = stacktrace.split( "\s*at" );
        for ( var j = 2; j <= arrayLen( stackTraceLines ); j++ ) {
            // Split into method/class info and file/line info
            var stackTraceLineElements = stackTraceLines[ j ].split( "\(" );
            if ( arrayLen( stackTraceLineElements ) == 2 ) {
                var stackTraceLineElement             = {};
                stackTraceLineElement[ "methodName" ] = trim( stackTraceLineElements[ 1 ] ).listLast( "." );
                stackTraceLineElement[ "className" ]  = stackTraceLineElements[ 1 ]
                    .listDeleteAt(
                        stackTraceLineElements[ 1 ].listLen( "." ),
                        "."
                    )
                    .trim();
                // Some Java stack trace frames don't include line numbers - handle both cases
                if ( stackTraceLineElements[ 2 ].reFindNoCase( "\:(?!\D+)" ) ) {
                    var parts                             = stackTraceLineElements[ 2 ].split( "\:(?!\D+)" );
                    stackTraceLineElement[ "fileName" ]   = parts[ 1 ].reReplace( "[\)\n\r]", "" ).trim();
                    stackTraceLineElement[ "lineNumber" ] = parts[ 2 ].reReplace( "[\)\n\r]", "" ).trim();
                } else {
                    stackTraceLineElement[ "fileName" ]   = stackTraceLineElements[ 2 ].reReplace( "[\)\n\r]", "" ).trim();
                    stackTraceLineElement[ "lineNumber" ] = javacast( "null", "" );
                }
                stackTraceData.append( stackTraceLineElement );
            }
        }
        return stackTraceData;
    }

}
