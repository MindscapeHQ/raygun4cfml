<cftry>
    <cfscript>
		a = 34;
		b = 0;
		c = a/b;
	</cfscript>
<cfcatch>
	<cfdump var="#cfcatch#"/>
    <cfset raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init("1FEgRf+W3S63sXcUf3y2oA==")/>
    <cfset result = raygun.send(cfcatch)/>
    <cfdump var="#result#"/>
</cfcatch>
</cftry>