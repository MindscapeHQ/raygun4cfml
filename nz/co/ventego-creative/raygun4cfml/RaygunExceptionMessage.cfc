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
					returnContent["Data"]["Type"] = arguments.issueDataStruct["RootCause"]["Type"];
					returnContent["Data"]["Name"] = arguments.issueDataStruct["RootCause"]["Name"];
				}
			}

			returnContent["ClassName"] = arguments.issueDataStruct.type;
			returnContent["CatchingMethod"] = "error struct";
			returnContent["Message"] = arguments.issueDataStruct.diagnostics;
			returnContent["StackTrace"] = [arguments.issueDataStruct.stacktrace];
			returnContent["FileName"] = "";
			returnContent["InnerError"] = "";

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>