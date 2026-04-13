/**
 * Manages configuration settings for the Raygun client.
 */
component accessors="true" {

    /**
     * Controls the maximum length of raw data that can be processed.
     * This helps prevent memory issues and ensures consistent API payload sizes.
     */
    property name="rawDataMaxLength" type="numeric";
    property name="statusCode"       type="numeric";
    property name="apiEndpoint"      type="string";
    property name="httpTimeout"      type="numeric";
    property name="maxRetries"       type="numeric";
    property name="retryDelay"       type="numeric";

    public RaygunSettings function init(
        numeric rawDataMaxLength = com.raygun.environment.RaygunConfig::RAW_DATA_MAX_LENGTH_DEFAULT,
        numeric statusCode       = com.raygun.environment.RaygunConfig::getDefaultStatusCode(),
        string apiEndpoint       = com.raygun.environment.RaygunConfig::getApiEndpoint(),
        numeric httpTimeout      = com.raygun.environment.RaygunConfig::getDefaultHttpTimeout(),
        numeric maxRetries       = com.raygun.environment.RaygunConfig::getDefaultMaxRetries(),
        numeric retryDelay       = com.raygun.environment.RaygunConfig::getDefaultRetryDelay()
    ) {
        setRawDataMaxLength( rawDataMaxLength );
        setStatusCode( statusCode );
        setApiEndpoint( apiEndpoint );
        setHttpTimeout( httpTimeout );
        setMaxRetries( maxRetries );
        setRetryDelay( retryDelay );
        return this;
    }

    public struct function getSettings() {
        return {
            "rawDataMaxLength" : getRawDataMaxLength(),
            "statusCode"       : getStatusCode(),
            "apiEndpoint"      : getApiEndpoint(),
            "httpTimeout"      : getHttpTimeout(),
            "maxRetries"       : getMaxRetries(),
            "retryDelay"       : getRetryDelay()
        };
    }

}
