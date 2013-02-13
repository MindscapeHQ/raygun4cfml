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

			returnContent["Data"] = {"TagContext" = arguments.issueDataStruct.TagContext};

			if (StructKeyExists(arguments.issueDataStruct,"RootCause"))
			{
				if (StructKeyExists(arguments.issueDataStruct["RootCause"],"Type") and arguments.issueDataStruct["RootCause"]["Type"] eq "expression")
				{
					returnContent["data"]["type"] = arguments.issueDataStruct["RootCause"]["Type"];
					returnContent["data"]["name"] = arguments.issueDataStruct["RootCause"]["Name"];
				}
			}

			returnContent["className"] = arguments.issueDataStruct.type;
			returnContent["catchingMethod"] = "error struct";
			returnContent["message"] = arguments.issueDataStruct.diagnostics;
			returnContent["stackTrace"] = [arguments.issueDataStruct.stacktrace];
			returnContent["fileName"] = "";
			returnContent["innerError"] = "";

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>