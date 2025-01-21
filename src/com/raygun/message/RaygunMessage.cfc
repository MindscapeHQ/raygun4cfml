/**
 * Core message builder for the Raygun error reporting system.
 * Coordinates the construction of the complete error payload by combining
 * timestamp data with detailed error information. The ISO8601 timestamp format
 * is required by Raygun's API for proper error chronology tracking.
 */
component accessors="true" {

    property name="settings" type="struct";

    // Handles the detailed error information including stack traces, request data, etc
    property name="raygunMessageDetails" type="RaygunMessageDetails";

    public RaygunMessage function init(
        RaygunMessageDetails raygunMessageDetails,
        struct settings = {}
    ) {
        setSettings( arguments.settings );
        setRaygunMessageDetails(
            !isNull( arguments.raygunMessageDetails ) && isInstanceOf(
                arguments.raygunMessageDetails,
                "RaygunMessageDetails"
            ) ? arguments.raygunMessageDetails : new RaygunMessageDetails( settings = getSettings() )
        );

        return this;
    }

    /**
     * Constructs the top-level Raygun message payload structure.
     * Combines an ISO8601 UTC timestamp with the detailed error data to create
     * a complete error report. The timestamp is converted to UTC to ensure
     * consistent error chronology across different server timezones.
     *
     * @issueData The struct containing issue data augmented with Raygun-specific data
     */
    public struct function build( required struct issueData ) {
        var returnContent = {};
        // Convert to UTC for consistent timestamps across different server timezones
        var ts            = dateConvert( "local2Utc", now() );

        returnContent[ "occurredOn" ] = ts.dateFormat( "yyyy-mm-dd" ) & "T" & ts.timeFormat( "HH:mm:ss" ) & "Z";
        returnContent[ "details" ]    = raygunMessageDetails.build( arguments.issueData );

        return returnContent;
    }

}
