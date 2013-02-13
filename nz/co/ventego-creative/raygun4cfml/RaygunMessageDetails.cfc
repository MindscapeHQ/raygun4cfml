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
			var messageEnvironmentDetails = createObject("component", "RaygunEnvironmentMessage").init();

			returnContent["version"] = JavaCast("null","");
			returnContent["machineName"] = CGI.SERVER_NAME;
			returnContent["error"] = messageErrorDetails.build(arguments.issueDataStruct);
			returnContent["request"] = messageRequestDetails.build();
			returnContent["client"] = messageClientDetails.build();
			returnContent["environment"] = messageEnvironmentDetails.build();
			returnContent["userCustomData"] = JavaCast("null","");
			returnContent["tags"] = JavaCast("null","");

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
