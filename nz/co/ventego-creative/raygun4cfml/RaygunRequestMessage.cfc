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
			// TODO: passing in the string is technically be wrong, API needs to change to accept string-only query strings - right now it's expecting a dictionary
			returnContent["queryString"] = CGI.QUERY_STRING;
			returnContent["headers"] = getHttpRequestData().headers;
			returnContent["data"] = CGI;
			returnContent["statusCode"] = JavaCast("null","");
			returnContent["form"] = JavaCast("null","");
			// TODO: check .net API - not form encoded body content
			returnContent["rawData"] = JavaCast("null","");

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>