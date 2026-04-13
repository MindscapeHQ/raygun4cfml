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
     * Loads the Raygun API key from .env.json, then RAYGUN_API_KEY env var, then placeholder
     */
    public void function onRequestStart() {
        var apiKey = "";

        // 1. Try .env.json in the samples directory
        //    Use expandPath() instead of getCurrentTemplatePath() so child Application.cfc
        //    files that call super.onRequestStart() resolve the correct path
        var envFile = expandPath( "/samples/.env.json" );
        if ( fileExists( envFile ) ) {
            try {
                var envData = deserializeJSON( fileRead( envFile ) );
                if ( isStruct( envData ) && envData.keyExists( "RAYGUN_API_KEY" ) && len( envData.RAYGUN_API_KEY ) ) {
                    apiKey = envData.RAYGUN_API_KEY;
                }
            } catch ( any e ) {
                // Invalid JSON — fall through
            }
        }

        // 2. Fall back to environment variable
        if ( !len( apiKey ) ) {
            try {
                var envValue = createObject( "java", "java.lang.System" ).getenv( "RAYGUN_API_KEY" );
                if ( !isNull( envValue ) && len( envValue ) ) {
                    apiKey = envValue;
                }
            } catch ( any e ) {
                // Environment variable not available
            }
        }

        // 3. Fall back to placeholder
        if ( !len( apiKey ) ) {
            apiKey = "<YOUR API KEY>";
        }

        variables.RAYGUNAPIKEY = apiKey;
        request.RAYGUNAPIKEY   = apiKey;
    }

}
