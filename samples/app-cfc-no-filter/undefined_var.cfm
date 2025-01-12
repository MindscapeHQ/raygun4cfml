<cfscript>
    // Intentionally trigger an error by referencing an undefined variable
    // This demonstrates Raygun's error capture capabilities without content filtering
    writeOutput(test5678);
</cfscript>