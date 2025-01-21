/**
 * Processes HTTP request data for Raygun error reports.
 * Captures essential request context including headers, form data, and raw request content
 * while gracefully handling cases where certain scopes might be unavailable.
 */
component accessors="true" {

    property name="settings" type="struct";

    public RaygunRequestMessage function init( struct settings = {} ) {
        setSettings( arguments.settings );

        return this;
    }

    /**
     * Builds a comprehensive snapshot of the HTTP request state.
     * Uses multiple data sources (CGI, FORM, URL scopes) with fallbacks to ensure
     * we capture as much context as possible even if some scopes are restricted.
     * Raw request data is truncated to prevent oversized payloads.
     */
    public struct function build() {
        var returnContent = {};

        // Safely access request data - some environments restrict getHTTPRequestData()
        try {
            var httpRequest = getHTTPRequestData();
        } catch ( any e ) {
            var httpRequest = {};
        }

        // Original CGI scope is often not writable, this can become a problem when using the RaygunContentFilter
        try {
            var localCGI = duplicate( CGI );
        } catch ( any e ) {
            var localCGI = {};
        }

        // Form scope might not exist for non-POST requests
        try {
            var localForm = duplicate( FORM );
        } catch ( any e ) {
            var localForm = {};
        }

        // URL parameters might be empty or restricted
        try {
            var localUrl = duplicate( URL );
        } catch ( any e ) {
            var localUrl = {};
        }

        // Build core request data, defaulting to null for missing values to maintain API compatibility
        returnContent = {
            "hostName" : ( len( CGI.HTTP_HOST ) ? CGI.HTTP_HOST : javacast( "null", "" ) ),
            "url"      : ( len( CGI.SCRIPT_NAME ) ? CGI.SCRIPT_NAME : javacast( "null", "" ) ) & (
                len( CGI.PATH_INFO ) ? CGI.PATH_INFO : javacast( "null", "" )
            ),
            "httpMethod"  : ( len( CGI.REQUEST_METHOD ) ? CGI.REQUEST_METHOD : javacast( "null", "" ) ),
            "iPAddress"   : ( len( CGI.REMOTE_ADDR ) ? CGI.REMOTE_ADDR : javacast( "null", "" ) ),
            "queryString" : ( len( CGI.QUERY_STRING ) ? CGI.QUERY_STRING : javacast( "null", "" ) ),
            "headers"     : ( httpRequest.keyExists( "headers" ) ? httpRequest.headers : javacast( "null", "" ) ),
            "data"        : localCGI,
            "form"        : localForm,
            "params"      : localUrl
        };

        // Only include raw request data for non-standard content types to avoid duplicating form data
        // Also enforces a max length to prevent oversized payloads
        if (
            len( CGI.CONTENT_TYPE ) && len( CGI.REQUEST_METHOD ) && CGI.CONTENT_TYPE != "text/html" && CGI.CONTENT_TYPE != "application/x-www-form-urlencoded" && CGI.REQUEST_METHOD != "GET"
        ) {
            var maxLength = (
                getSettings().keyExists( "rawDataMaxLength" ) ? getSettings().rawDataMaxLength : com.raygun.environment.RaygunConfig::getRawDataMaxLengthDefault()
            );
            returnContent[ "rawData" ] = left(
                ( httpRequest.keyExists( "content" ) ) ? httpRequest.content : javacast( "null", "" ),
                maxLength
            );
        } else {
            returnContent[ "rawData" ] = javacast( "null", "" );
        }

        return returnContent;
    }

}
