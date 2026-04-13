/**
 * Records a single breadcrumb entry for Raygun error reports.
 * Breadcrumbs provide a trail of events leading up to an error,
 * helping developers understand the sequence of actions that triggered it.
 */
component accessors="true" {

    property name="timestamp"  type="string" default="";
    property name="level"      type="string" default="info";
    property name="type"       type="string" default="manual";
    property name="category"   type="string" default="";
    property name="message"    type="string" default="";
    property name="className"  type="string" default="";
    property name="methodName" type="string" default="";
    property name="lineNumber" type="numeric";
    property name="customData" type="struct";

    static {
        VALID_LEVELS = [ "debug", "info", "warning", "error" ];
    }

    public RaygunBreadcrumbMessage function init(
        required string message,
        string level      = "info",
        string type       = "manual",
        string category   = "",
        string className  = "",
        string methodName = "",
        numeric lineNumber,
        struct customData
    ) {
        var ts = dateConvert( "local2Utc", now() );
        setTimestamp( ts.dateFormat( "yyyy-mm-dd" ) & "T" & ts.timeFormat( "HH:mm:ss" ) & "Z" );
        setMessage( arguments.message );
        setLevel( validateLevel( arguments.level ) );
        setType( arguments.type );
        setCategory( arguments.category );
        setClassName( arguments.className );
        setMethodName( arguments.methodName );

        if ( arguments.keyExists( "lineNumber" ) ) {
            setLineNumber( arguments.lineNumber );
        }

        if ( arguments.keyExists( "customData" ) ) {
            setCustomData( arguments.customData );
        }

        return this;
    }

    public struct function build() {
        var result = {
            "timestamp" : getTimestamp(),
            "level"     : getLevel(),
            "type"      : getType(),
            "category"  : getCategory(),
            "message"   : getMessage(),
            "className" : getClassName(),
            "methodName": getMethodName()
        };

        try {
            if ( getLineNumber() > 0 ) {
                result[ "lineNumber" ] = getLineNumber();
            }
        } catch ( any e ) {
            // lineNumber not set
        }

        try {
            var cd = getCustomData();
            if ( isStruct( cd ) && !cd.isEmpty() ) {
                result[ "customData" ] = cd;
            }
        } catch ( any e ) {
            // customData not set
        }

        return result;
    }

    private string function validateLevel( required string level ) {
        for ( var valid in static.VALID_LEVELS ) {
            if ( compareNoCase( arguments.level, valid ) == 0 ) {
                return lCase( arguments.level );
            }
        }
        return "info";
    }

}
