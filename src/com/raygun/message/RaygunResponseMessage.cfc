/**
 * Represents the response information to be included in the Raygun message.
 */
component accessors="true" {

    property name="settings" type="struct";

    public RaygunResponseMessage function init( struct settings = {} ) {
        setSettings( arguments.settings );
        
        return this;
    }

    /**
     * Determines the status code based on the exception type.
     * @param errorData The error structure from the crash report
     */
    private numeric function determineStatusCode( required struct errorData ) {
        if ( errorData.type == "MissingInclude" ) {
            return 404;
        } 
        
        return ( getSettings().keyExists( "statusCode" ) ? getSettings().statusCode : com.raygun.environment.RaygunConfig::getDefaultStatusCode() );
    }

    public struct function build( required struct errorData ) {
        return {
            "statusCode": determineStatusCode( arguments.errorData )
        };
    }
} 
