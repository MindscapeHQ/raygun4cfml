<cfscript>
    // Deliberately trigger a division by zero error to demonstrate
    // custom exception handling and error propagation to Raygun
    try {
        a = 14;
        b = 0; 
        c = a/b; // Forces division by zero exception
    } catch(any e) {
        // Re-throw with custom error details to provide more context
        // This allows the error to bubble up to the global handler
        // while preserving the original error chain
        throw( 
            message = "This is a custom exception message", 
            type = "CustomException", 
            detail = "This is a custom exception detail", 
            errorcode = "1234567890", 
            extendedinfo = "The file catch_throw.cfm had an issue. Retrowing it.");
    }
</cfscript>