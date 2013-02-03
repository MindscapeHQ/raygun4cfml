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
			var messageErrorDetails = createObject("component", "RaygunExceptionMessage").init();
			var messageRequestDetails = createObject("component", "RaygunRequestMessage").init();
			var messageClientDetails = createObject("component", "RaygunClientMessage").init();
			var messageEnvironmentDetails = createODBCDate("component", "RaygunEnvironmentMessage").init();

			returnContent["MachineName"] = "kaitest";
			returnContent["Error"] = messageErrorDetails.build(arguments.issueDataStruct);
			returnContent["Request"] = messageRequestDetails.build();
			returnContent["Client"] = messageClientDetails.build();
			returnContent["Environment"] = messageEnvironmentDetails.build();

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
