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
        RAYGUN_CLIENT_VERSION = "2.0.1";
        RAYGUN_CLIENT_URL     = "https://github.com/MindscapeHQ/raygun4cfml";

        // New default status code
        DEFAULT_STATUS_CODE = 500;
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

}
