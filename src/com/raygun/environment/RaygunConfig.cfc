/**
 * Manages core default configuration settings and constants for the Raygun CFML client.
 * This component centralizes version information and default settings to ensure
 * consistent behavior across the SDK.
 */
component {

    static {
        // Limits payload size to prevent memory issues and ensure API compatibility
        RAW_DATA_MAX_LENGTH_DEFAULT = 4096;

        // Client identifiers used for error tracking and debugging
        RAYGUN_CLIENT_NAME    = "raygun4cfml";
        RAYGUN_CLIENT_VERSION = "2.1.0";
        RAYGUN_CLIENT_URL     = "https://github.com/MindscapeHQ/raygun4cfml";

        // New default status code
        DEFAULT_STATUS_CODE = 500;

        API_ENDPOINT         = "https://api.raygun.com/entries";
        LOG_FILE_NAME        = "Raygun4CFML";
        CONTENT_TYPE_HTML    = "text/html";
        CONTENT_TYPE_FORM    = "application/x-www-form-urlencoded";
        HTTP_METHOD_GET      = "GET";
        FORM_FIELD_MAX_LENGTH = 256;
        MAX_PAYLOAD_SIZE     = 131072;
        DEFAULT_HTTP_TIMEOUT = 10;
    }

    /**
     * Returns the maximum allowed length for raw data payloads.
     * This limit helps prevent memory issues when processing large error payloads
     * and ensures consistent API behavior across different CFML engines.
     */
    public static function getRawDataMaxLengthDefault() {
        return static.RAW_DATA_MAX_LENGTH_DEFAULT;
    }

    /**
     * Provides the client identifier used in API communications.
     * This helps Raygun distinguish between different client libraries
     * for proper error attribution and debugging.
     */
    public static function getRaygunClientName() {
        return static.RAYGUN_CLIENT_NAME;
    }

    /**
     * Returns the semantic version of this client library.
     * Used by Raygun to track client versions and identify potential
     * version-specific issues or incompatibilities.
     */
    public static function getRaygunClientVersion() {
        return static.RAYGUN_CLIENT_VERSION;
    }

    /**
     * Provides the repository URL for the client library.
     * Allows users to easily find documentation, report issues,
     * and contribute to the codebase.
     */
    public static function getRaygunClientUrl() {
        return static.RAYGUN_CLIENT_URL;
    }

    /**
     * Returns the default HTTP status code for error responses.
     */
    public static function getDefaultStatusCode() {
        return static.DEFAULT_STATUS_CODE;
    }

    /**
     * Returns the Raygun API endpoint URL for submitting error reports.
     */
    public static function getApiEndpoint() {
        return static.API_ENDPOINT;
    }

    /**
     * Returns the log file name used for async error logging.
     */
    public static function getLogFileName() {
        return static.LOG_FILE_NAME;
    }

    /**
     * Returns the HTML content type string used for request filtering.
     */
    public static function getContentTypeHtml() {
        return static.CONTENT_TYPE_HTML;
    }

    /**
     * Returns the form-urlencoded content type string used for request filtering.
     */
    public static function getContentTypeForm() {
        return static.CONTENT_TYPE_FORM;
    }

    /**
     * Returns the HTTP GET method string used for request filtering.
     */
    public static function getHttpMethodGet() {
        return static.HTTP_METHOD_GET;
    }

    /**
     * Returns the maximum character length for individual form field values.
     */
    public static function getFormFieldMaxLength() {
        return static.FORM_FIELD_MAX_LENGTH;
    }

    /**
     * Returns the maximum payload size in bytes accepted by the Raygun API.
     */
    public static function getMaxPayloadSize() {
        return static.MAX_PAYLOAD_SIZE;
    }

    /**
     * Returns the default HTTP timeout in seconds for API requests.
     */
    public static function getDefaultHttpTimeout() {
        return static.DEFAULT_HTTP_TIMEOUT;
    }

}
