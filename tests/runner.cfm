<cfscript>
    r = CreateObject("component","testbox.system.TestBox");
    r.init(directory="tests");
</cfscript>

<cfoutput>#r.run()#</cfoutput>
