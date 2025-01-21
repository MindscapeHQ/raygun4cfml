/**
 * Application.cfc - Main application configuration component
 * Handles core framework setup and request lifecycle management
 */
component {

    // Map the /com directory to allow component resolution from the src folder
    // This enables cleaner imports without needing full file paths
    this.mappings = { "/com" : expandPath( "/src/com" ) };

    /**
     * Runs at the start of each request
     * Sets up the Raygun error tracking API key for exception monitoring
     */
    public void function onRequestStart() {
        variables.RAYGUNAPIKEY = "erHT5l1N2VPfHW3E82kQQ";
    }

}
