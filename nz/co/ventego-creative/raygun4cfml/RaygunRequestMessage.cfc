<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfscript>
			var returnContent = {};

			returnContent["hostName"] = CGI.HTTP_HOST;
			returnContent["url"] = CGI.SCRIPT_NAME;
			returnContent["httpMethod"] = CGI.REQUEST_METHOD;
			returnContent["ipAddress"] = CGI.REMOTE_ADDR;
			returnContent["queryString"] = CGI.QUERY_STRING;
			returnContent["headers"] = getHttpRequestData().headers;
			returnContent["data"] = getHttpRequestData().content;
			returnContent["statusCode"] = JavaCast("null","");

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>