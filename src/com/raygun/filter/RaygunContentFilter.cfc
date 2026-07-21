/**
 * Handles content filtering for Raygun payloads to prevent sensitive data from being sent.
 * This component allows configurable filtering of both top-level message data and nested JSON
 * content within rawData fields.
 */
component accessors="true" {

    /**
     * Array of filter matchers, each containing a filter pattern and replacement value
     */
    property name="filter" type="array";

    public RaygunContentFilter function init( array filter = [] ) {
        variables.filter = arguments.filter;
        return this;
    }

    /**
     * Applies content filtering rules to the message payload before sending to Raygun.
     * Handles both direct key matches in the message structure and nested JSON content
     * within rawData fields to ensure comprehensive filtering of sensitive data.
     *
     * @messageData The Raygun message payload to filter
     */
    public struct function apply( required struct messageData ) {
        var filter = getFilter();

        for ( var matcher in filter ) {
            var isWildcard = ( find( "*", matcher.filter ) > 0 );

            if ( isWildcard ) {
                // Wildcard patterns require recursive key walking
                filterStructByPattern( arguments.messageData, matcher.filter, matcher.replacement );
            } else {
                // Exact match uses the efficient built-in findKey
                var findKeysByFilter = arguments.messageData.findKey( matcher.filter, "all" );

                for ( var element in findKeysByFilter ) {
                    if ( isSimpleValue( element.value ) ) {
                        element.owner[ matcher.filter ] = matcher.replacement;
                    }
                }
            }

            // Handle the special case of rawData fields that may contain JSON
            // This ensures sensitive data nested in JSON payloads is also filtered
            if (
                arguments.messageData.keyExists( "details" )
                && isStruct( arguments.messageData.details )
                && arguments.messageData.details.keyExists( "request" )
                && isStruct( arguments.messageData.details.request )
                && arguments.messageData.details.request.keyExists( "rawData" )
                && !isNull( arguments.messageData.details.request.rawData )
                && isJSON( arguments.messageData.details.request.rawData )
            ) {
                var rawDataJSON = deserializeJSON( arguments.messageData.details.request.rawData );

                if ( isWildcard ) {
                    filterStructByPattern( rawDataJSON, matcher.filter, matcher.replacement );
                } else {
                    var findRawDataKeysByFilter = rawDataJSON.findKey( matcher.filter, "all" );

                    for ( var element in findRawDataKeysByFilter ) {
                        element.owner[ matcher.filter ] = matcher.replacement;
                    }
                }

                arguments.messageData.details.request.rawData = serializeJSON( rawDataJSON );
            }
        }

        return arguments.messageData;
    }

    /**
     * Recursively walks a struct and replaces values whose keys match a glob pattern.
     * Supports * as a wildcard matching zero or more characters.
     *
     * @data The struct or array to filter
     * @pattern The glob pattern (e.g. "pass*", "*secret*", "credit*")
     * @replacement The replacement value for matched keys
     */
    private void function filterStructByPattern(
        required any data,
        required string pattern,
        required string replacement
    ) {
        if ( isStruct( arguments.data ) ) {
            var regex = globToRegex( arguments.pattern );

            for ( var key in arguments.data ) {
                if ( isNull( arguments.data[ key ] ) ) {
                    continue;
                } else if ( reFindNoCase( regex, key ) > 0 && isSimpleValue( arguments.data[ key ] ) ) {
                    arguments.data[ key ] = arguments.replacement;
                } else if ( isStruct( arguments.data[ key ] ) || isArray( arguments.data[ key ] ) ) {
                    filterStructByPattern( arguments.data[ key ], arguments.pattern, arguments.replacement );
                }
            }
        } else if ( isArray( arguments.data ) ) {
            for ( var item in arguments.data ) {
                if ( isStruct( item ) || isArray( item ) ) {
                    filterStructByPattern( item, arguments.pattern, arguments.replacement );
                }
            }
        }
    }

    /**
     * Converts a simple glob pattern with * wildcards to a regex pattern.
     * Escapes regex-special characters and replaces * with .*
     */
    private string function globToRegex( required string pattern ) {
        var result      = "";
        var specialChars = ".+?^${}()|[]\";
        var chars        = arguments.pattern.toCharArray();

        for ( var c in chars ) {
            if ( c == "*" ) {
                result &= ".*";
            } else if ( find( c, specialChars ) > 0 ) {
                result &= "\" & c;
            } else {
                result &= c;
            }
        }

        return "^" & result & "$";
    }

}
