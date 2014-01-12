<cfscript>
    r = CreateObject("component","testbox.system.testing.TestBox");
    r.init(directory="raygun4cfml.tests.raygun4cfml.unit");
</cfscript>

<cfoutput>#r.run()#</cfoutput>
