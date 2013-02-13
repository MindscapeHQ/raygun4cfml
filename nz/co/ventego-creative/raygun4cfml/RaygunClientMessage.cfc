<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfscript>
			var returnContent = {};

			returnContent["name"] = "raygun4cfml";
			returnContent["version"] = "0.5.0.0alpha";
			returnContent["clientUrl"] = "https://github.com/MindscapeHQ/raygun4cfml";
			returnContent["apiVersion"] = 1;

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
