<cfscript>
    // Populate test data into form/url scopes to demonstrate Raygun's content filtering capabilities
    // Age is used as a non-sensitive field that won't be filtered
    form["age"] = 38;

    // Option 1 (Commented out): 
    // Shows how simple string values matching filter patterns are handled
    // The content filter will replace this with a placeholder to protect sensitive data
    // form["password"] = "MyPassword123";

    // Option 2:
    // Demonstrates filtering behavior for complex/nested data structures
    // While the key matches a filter pattern, the nested values don't contain sensitive data
    // This tests the content filter's ability to recursively inspect and selectively filter
    form["password"] = { "a" = 4, "b" = 5 };

    // Additional cases for pattern matching on different key names and value types
    // "Secret" and "creditcard" patterns should trigger content filtering
    form["ASecretTokenThing"] = "gfgfgfdfgdw432443543";
    url["creditcard"] = "6565654";

    // Intentionally trigger an error by referencing undefined variable
    // This allows testing of Raygun's error capture and filtering in combination
    writeOutput(test5678);
</cfscript>