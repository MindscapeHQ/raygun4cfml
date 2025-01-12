/**
 * Internal utility component for CFML engine detection and compatibility checks.
 * Different CFML engines handle certain operations differently (like Java integration,
 * scope access, and error handling), so we need to detect the environment to
 * adjust our behavior accordingly. This helps maintain consistent error reporting
 * across all supported CFML platforms.
 */
component {

    /**
     * Detects Lucee CFML engine to handle its unique scope access patterns
     * and Java integration methods. Lucee's implementation of certain core
     * functions differs from ACF, particularly around error handling.
     */
    public static boolean function isLucee() {
        var serverInfo = com.raygun.tools.ProductCheck::getServerProductInfo();
        return !serverInfo.isEmpty() && serverInfo[ "cfmlEngine" ] == "Lucee";
    }

    /**
     * Identifies ACF 2021 environments to accommodate its specific error
     * handling patterns and security restrictions. ACF 2021 introduced
     * changes to scope access and Java integration that require special handling.
     */
    public static boolean function isACF2021() {
        var serverInfo = com.raygun.tools.ProductCheck::getServerProductInfo();
        return !serverInfo.isEmpty() && serverInfo[ "cfmlEngine" ] == "ACF" && serverInfo[ "serverMainVersion" ] == "2021";
    }

    /**
     * Detects ACF 2023 to handle its enhanced security features and
     * modernized error handling system. ACF 2023 includes significant
     * changes to thread handling and scope access that can affect error capture.
     */
    public static boolean function isACF2023() {
        var serverInfo = com.raygun.tools.ProductCheck::getServerProductInfo();
        return !serverInfo.isEmpty() && serverInfo[ "cfmlEngine" ] == "ACF" && serverInfo[ "serverMainVersion" ] == "2023";
    }

    /**
     * Identifies Boxlang environments which require special handling due to
     * their unique implementation of CFML standards. Boxlang currently has known issues
     * with certain scope access (see BL-901, BL-902) that need workarounds.
     */
    public static boolean function isBoxlang() {
        var serverInfo = com.raygun.tools.ProductCheck::getServerProductInfo();
        return !serverInfo.isEmpty() && serverInfo[ "cfmlEngine" ] == "Boxlang";
    }

}
