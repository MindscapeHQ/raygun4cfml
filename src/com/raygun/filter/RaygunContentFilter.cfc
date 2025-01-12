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
        setFilter( filter );
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
            // Find all matching keys in the main message structure that need filtering
            var findKeysByFilter = arguments.messageData.findKey( matcher.filter, "all" );

            // Replace matched values, but only for simple values since complex objects
            // should not be replaced with string placeholders
            for ( var element in findKeysByFilter ) {
                if ( isSimpleValue( element.value ) ) {
                    element.owner[ matcher.filter ] = matcher.replacement;
                }
            }

            // Handle the special case of rawData fields that may contain JSON
            // This ensures sensitive data nested in JSON payloads is also filtered
            if ( !isNull( arguments.messageData.details.request.rawData ) && isJSON( arguments.messageData.details.request.rawData ) ) {
                var rawDataJSON             = deserializeJSON( arguments.messageData.details.request.rawData );
                var findRawDataKeysByFilter = rawDataJSON.findKey( matcher.filter, "all" );

                for ( var element in findRawDataKeysByFilter ) {
                    element.owner[ matcher.filter ] = matcher.replacement;
                }
                // Re-serialize the filtered rawData JSON back into the message
                arguments.messageData.details.request.rawData = serializeJSON( rawDataJSON );
            }
        }

        return arguments.messageData;
    }

}
