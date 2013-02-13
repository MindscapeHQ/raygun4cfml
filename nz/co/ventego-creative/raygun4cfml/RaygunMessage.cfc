<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfargument name="issueDataStruct" type="struct" required="yes">

		<cfscript>
			var returnContent = {};
			var messageDetails = createObject("component", "RaygunMessageDetails").init();
			var ts = now();

			returnContent["occurredOn"] = "#DateFormat(ts,'yyyy-mm-dd')#T#timeFormat(ts,'HH:mm:ss')#Z";
			returnContent["details"] = messageDetails.build(arguments.issueDataStruct);

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>