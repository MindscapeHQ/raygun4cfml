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

        // Build core request data using safe local copies, defaulting to null for missing values
        var cgiVal = function( required string key ) {
            return ( localCGI.keyExists( arguments.key ) && len( localCGI[ arguments.key ] ) ) ? localCGI[ arguments.key ] : javacast(
                "null",
                ""
            );
        };

        var truncatedForm = truncateFormFields( localForm );

        returnContent = {
            "hostName" : cgiVal( "HTTP_HOST" ),
            "url"      : ( !isNull( cgiVal( "SCRIPT_NAME" ) ) ? cgiVal( "SCRIPT_NAME" ) : "" ) & (
                !isNull( cgiVal( "PATH_INFO" ) ) ? cgiVal( "PATH_INFO" ) : ""
            ),
            "httpMethod"  : cgiVal( "REQUEST_METHOD" ),
            "iPAddress"   : cgiVal( "REMOTE_ADDR" ),
            "queryString" : cgiVal( "QUERY_STRING" ),
            "headers"     : ( httpRequest.keyExists( "headers" ) ? httpRequest.headers : javacast( "null", "" ) ),
            "data"        : localCGI,
            "form"        : truncatedForm,
            "params"      : localUrl
        };

        // Normalize url to null if empty
        if ( !len( returnContent[ "url" ] ) ) {
            returnContent[ "url" ] = javacast( "null", "" );
        }

        // Only include raw request data for non-standard content types to avoid duplicating form data
        // Also enforces a max length to prevent oversized payloads
        var contentType   = localCGI.keyExists( "CONTENT_TYPE" ) ? localCGI[ "CONTENT_TYPE" ] : "";
        var requestMethod = localCGI.keyExists( "REQUEST_METHOD" ) ? localCGI[ "REQUEST_METHOD" ] : "";
        if (
            len( contentType ) && len( requestMethod ) && contentType != com.raygun.environment.RaygunConfig::getContentTypeHtml() && contentType != com.raygun.environment.RaygunConfig::getContentTypeForm() && requestMethod != com.raygun.environment.RaygunConfig::getHttpMethodGet()
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

    /**
     * Truncates form field values to the configured maximum length
     * to prevent oversized payloads per the Raygun API spec.
     */
    private struct function truncateFormFields( required struct formData ) {
        var maxLen = com.raygun.environment.RaygunConfig::getFormFieldMaxLength();
        var result = {};

        for ( var key in arguments.formData ) {
            if ( isSimpleValue( arguments.formData[ key ] ) && len( arguments.formData[ key ] ) > maxLen ) {
                result[ key ] = left( arguments.formData[ key ], maxLen );
            } else {
                result[ key ] = arguments.formData[ key ];
            }
        }

        return result;
    }

}
