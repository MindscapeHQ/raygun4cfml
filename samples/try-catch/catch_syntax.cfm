<cfscript>
    // API key is loaded automatically by Application.cfc
    // from samples/.env.json or the RAYGUN_API_KEY environment variable

    // This code demonstrates a key difference in how Adobe CF and Lucee handle syntax errors:
    // Adobe ColdFusion compiles this code and then fails at runtime. So, ACF will log this to Raygun just fine.
    //
    // Lucee however will fail at compile time and not execute the code - so it will not log to Raygun in here. 
    // If you had a global error handler in Lucee or on the servlet engine, it could be caught there.
    try {
        a = 14;
        b z 0;  // Intentional syntax error to demonstrate platform differences
    } catch(any e) {
        // Initialize Raygun client to track this error
        raygun = new com.raygun.RaygunClient(
            apiKey = request.RAYGUNAPIKEY,
            appVersion = "3.4.5"
        );
        // Send error details to Raygun for monitoring and debugging
        result = raygun.send(e);
    }
</cfscript>