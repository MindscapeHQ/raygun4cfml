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

			returnContent["Data"] = {};
			returnContent["ClassName"] = "System.IndexOutOfRangeException";
			returnContent["CatchingMethod"] = "";
			returnContent["Message"] = "IndexOutOfRangeException: Message99";
			returnContent["StackTrace"] = [];
			returnContent["FileName"] = "";
			returnContent["InnerError"] = "";

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>