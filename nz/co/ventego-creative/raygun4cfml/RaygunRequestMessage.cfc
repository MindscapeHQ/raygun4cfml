<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfscript>
			var returnContent = {};

			returnContent["hostName"] = "123";
			returnContent["url"] = "456";
			returnContent["httpMethod"] = "789;";
			returnContent["ipAddress"] = "111.111.111.111";
			returnContent["queryString"] = "gdfgfdf";
			returnContent["headers"] = "gfdgfgfd";
			returnContent["data"] = "gfgfgfd";
			returnContent["statusCode"] ="402";

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
