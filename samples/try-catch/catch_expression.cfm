<cfscript>
    // API key for Raygun error tracking service
    RAYGUNAPIKEY = "<YOUR API KEY>";

    // Deliberately trigger a division by zero error to demonstrate 
    // error handling and reporting to Raygun in a simple scenario
    try {
        a = 14;
        b = 0;
        c = a/b; // Forces division by zero exception
    } catch(any e) {
        // Initialize Raygun client to track production errors
        raygun = new com.raygun.RaygunClient(
            apiKey = RAYGUNAPIKEY,
            appVersion = "3.4.5"
        );
        // Send error details to Raygun for monitoring and alerting
        result = raygun.send(e);
    }
</cfscript>