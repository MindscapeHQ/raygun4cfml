/**
 * Manages configuration settings for the Raygun client.
 */
component accessors="true" {

    /**
     * Controls the maximum length of raw data that can be processed.
     * This helps prevent memory issues and ensures consistent API payload sizes.
     */
    property name="rawDataMaxLength" type="numeric";
    property name="statusCode" type="numeric";

    public RaygunSettings function init( numeric rawDataMaxLength = com.raygun.environment.RaygunConfig::RAW_DATA_MAX_LENGTH_DEFAULT, numeric statusCode = com.raygun.environment.RaygunConfig::getDefaultStatusCode() ) {
        setRawDataMaxLength( rawDataMaxLength );
        setStatusCode( statusCode );
        return this;
    }

    public struct function getSettings() {
        return { "rawDataMaxLength" : getRawDataMaxLength(), "statusCode" : getStatusCode() };
    }

}
