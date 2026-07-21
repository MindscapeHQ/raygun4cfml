/**
 * Builds environment-specific data for Raygun error reports.
 * This component gathers system information like memory usage, OS details,
 * and CFML engine specifics to provide context for error diagnosis.
 */
component {

    public RaygunEnvironmentMessage function init() {
        return this;
    }

    /**
     * Constructs a detailed environment snapshot for error context.
     * Uses Java system properties and management beans to gather runtime metrics.
     * Falls back gracefully if certain metrics are unavailable due to security
     * restrictions or JVM limitations.
     */
    public struct function build() {
        var returnContent = {};
        // Access core Java runtime for system properties
        var runtime       = createObject( "java", "java.lang.System" );
        var props         = runtime.getProperties();
        // Used for accessing JVM metrics and diagnostics
        var mf            = createObject(
            "java",
            "java.lang.management.ManagementFactory"
        );
        var heapMem = "";
        var osbean  = "";

        // Capture basic system architecture and runtime details
        returnContent[ "architecture" ]   = props[ "os.arch" ];
        returnContent[ "osVersion" ]      = props[ "os.version" ];
        // Combine VM details to provide complete runtime context
        returnContent[ "packageVersion" ] = props[ "java.vm.vendor" ] & " | " & props[ "java.runtime.version" ] & " | " & props[
            "java.vm.name"
        ];
        returnContent[ "platform" ] = props[ "os.name" ];

        // Safely gather heap memory metrics, falling back to null if unavailable
        try {
            heapMem                                   = mf.getMemoryMXBean().getHeapMemoryUsage();
            returnContent[ "availableVirtualMemory" ] = heapMem.getCommitted() - heapMem.getUsed();
            returnContent[ "totalVirtualMemory" ]     = heapMem.getCommitted();
        } catch ( any e ) {
            // Some environments restrict access to memory metrics
            returnContent[ "availableVirtualMemory" ] = javacast( "null", "" );
            returnContent[ "totalVirtualMemory" ]     = javacast( "null", "" );
        }

        // Gather physical memory metrics when available
        try {
            osbean                                     = mf.getOperatingSystemMXBean();
            returnContent[ "availablePhysicalMemory" ] = osbean.getFreePhysicalMemorySize();
            returnContent[ "totalPhysicalMemory" ]     = osbean.getTotalPhysicalMemorySize();
        } catch ( any e ) {
            // Handle restricted access to OS-level metrics
            returnContent[ "availablePhysicalMemory" ] = javacast( "null", "" );
            returnContent[ "totalPhysicalMemory" ]     = javacast( "null", "" );
        }

        // Include CFML engine details for runtime context
        returnContent[ "model" ] = com.raygun.tools.ProductCheck::getServerProductInfo().cfmlEngine & " " & com.raygun.tools.ProductCheck::getServerProductInfo().serverVersion;

        // Processor count for capacity context
        try {
            returnContent[ "processorCount" ] = createObject( "java", "java.lang.Runtime" ).getRuntime().availableProcessors();
        } catch ( any e ) {
            returnContent[ "processorCount" ] = javacast( "null", "" );
        }

        // Locale and UTC offset for regional context
        try {
            returnContent[ "locale" ] = createObject( "java", "java.util.Locale" ).getDefault().toString();
        } catch ( any e ) {
            returnContent[ "locale" ] = javacast( "null", "" );
        }

        try {
            var rawOffset                = createObject( "java", "java.util.TimeZone" ).getDefault().getRawOffset();
            returnContent[ "utcOffset" ] = javacast( "double", rawOffset / 3600000 );
        } catch ( any e ) {
            returnContent[ "utcOffset" ] = javacast( "null", "" );
        }

        return returnContent;
    }

}
