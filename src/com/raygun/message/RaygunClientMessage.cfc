/**
 * Builds the client identification portion of the Raygun message payload.
 * This metadata helps Raygun track which client library version reported an error,
 * enabling better debugging and version-specific issue tracking.
 */
component {

    public RaygunClientMessage function init() {
        return this;
    }

    /**
     * Constructs the client identification data structure.
     * This information is included in every error report to help identify
     * the source client library and version for proper error attribution.
     */
    public struct function build() {
        var returnContent = {
            "name"      : com.raygun.environment.RaygunConfig::getRaygunClientName(),
            "version"   : com.raygun.environment.RaygunConfig::getRaygunClientVersion(),
            "clientUrl" : com.raygun.environment.RaygunConfig::getRaygunClientUrl()
        };

        return returnContent;
    }

}
