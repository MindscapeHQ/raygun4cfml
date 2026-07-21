<!--- API key is loaded automatically by Application.cfc --->
<!--- from samples/.env.json or the RAYGUN_API_KEY environment variable --->
<cftry>
    <!--- Attempt database query that may fail --->
    <cfquery datasource="something">
        SELECT glarfx bo banana
    </cfquery> 
    <cfcatch type="any">
        <!--- Display error details for debugging --->
        <cfdump var="#cfcatch#">
        <cfscript>
            // Initialize Raygun client to track production errors
            raygun = new com.raygun.RaygunClient(apiKey = request.RAYGUNAPIKEY, appVersion = "3.4.7");
            // Send error details to Raygun for monitoring and alerting
            result = raygun.send(cfcatch);
        </cfscript>
    </cfcatch>
</cftry> 