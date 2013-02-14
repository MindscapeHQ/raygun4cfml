<!---
Copyright 2013 Kai Koenig, Ventego Creative Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

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