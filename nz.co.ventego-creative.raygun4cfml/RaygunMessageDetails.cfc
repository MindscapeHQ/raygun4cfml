<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfargument name="errorStruct" type="struct" required="yes">

		<cfscript>
			var returnContent = {};
			var messageErrorDetails = createObject("component", "RaygunExpectionMessage").init();
			var messageRequestDetails = createObject("component", "RaygunRequestMessage").init();
			var messageClientDetails = createObject("component", "RaygunClientMessage").init();

			returnContent["MachineName"] = "kaitest";
			returnContent["Error"] = messageErrorDetails.build(arguments.errorStruct);
			returnContent["Request"] = messageRequestDetails.build();
			returnContent["Client"] = messageClientDetails.build();

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
