/**
 * Handles custom user data for Raygun error reports.
 * Allows developers to attach arbitrary diagnostic information to error reports
 * to provide additional context about the state of the application when an error occurred.
 * This data appears in the "Custom Data" tab in the Raygun dashboard.
 */
component accessors="true" {

    // Stores arbitrary key-value pairs that will be included in the error report
    property name="userCustomData" type="struct";

    public RaygunUserCustomData function init( struct userCustomData = {} ) {
        setUserCustomData( userCustomData );
        return this;
    }

    /**
     * Adds a key-value pair to the userCustomData struct.
     * If the key already exists, its value will be updated.
     *
     * @param key The key to add or update in the custom data.
     * @param value The value to associate with the key.
     */
    public function add(
        required string key,
        required any value
    ) {
        variables.userCustomData[ key ] = value;
    }

    /**
     * Returns the custom data structure for inclusion in the error payload.
     * Called during error report construction to attach the custom data.
     */
    public function build() {
        return getUserCustomData();
    }

}
