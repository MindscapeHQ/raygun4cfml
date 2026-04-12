<cfscript>
    r = CreateObject("component","testbox.system.TestBox");
    r.init(directory="tests");

    // Support ?reporter=json|simple|text|min for automation; default is HTML
    reporter = URL.keyExists("reporter") ? URL.reporter : "";
</cfscript>

<cfoutput>#r.run(reporter=reporter)#</cfoutput>
