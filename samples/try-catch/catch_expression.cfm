<cfscript>
    // API key is loaded automatically by Application.cfc
    // from samples/.env.json or the RAYGUN_API_KEY environment variable

    // Deliberately trigger a division by zero error to demonstrate 
    // error handling and reporting to Raygun in a simple scenario
    try {
        a = 14;
        b = 0;
        c = a/b; // Forces division by zero exception
    } catch(any e) {
        // Initialize Raygun client to track production errors
        raygun = new com.raygun.RaygunClient(
            apiKey = request.RAYGUNAPIKEY,
            appVersion = "3.4.5"
        );
        // Send error details to Raygun for monitoring and alerting
        result = raygun.send(e);
    }
</cfscript>