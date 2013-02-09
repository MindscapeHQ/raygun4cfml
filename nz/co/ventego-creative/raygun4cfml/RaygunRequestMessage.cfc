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
			// TODO: passing in the string might be wrong, key/value pairs instead?
			returnContent["queryString"] = CGI.QUERY_STRING;
			returnContent["headers"] = getHttpRequestData().headers;
			// TODO: Alternatively throw the whole CGI scope in here
			returnContent["data"] = getHttpRequestData().content;
			returnContent["statusCode"] = JavaCast("null","");
			returnContent["form"] = JavaCast("null","");
			returnContent["rawData"] = JavaCast("null",null);

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>