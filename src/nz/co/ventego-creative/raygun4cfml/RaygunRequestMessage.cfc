<!---
Copyright 2022 Kai Koenig, Ventego Creative Ltd

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

    <cffunction name="build" access="public" output="false" returntype="struct">

        <cfargument name="issueDataStruct" type="struct" required="yes">

        <cfscript>
            var returnContent = {};
            var rawDataMaxLength = 4096;
            var httpRequest = getHttpRequestData();

            returnContent["hostName"] = duplicate(CGI.HTTP_HOST);
            returnContent["url"] = duplicate(CGI.SCRIPT_NAME) & duplicate(CGI.PATH_INFO)
            returnContent["httpMethod"] = duplicate(CGI.REQUEST_METHOD);
            returnContent["iPAddress"] = duplicate(CGI.REMOTE_ADDR);
            returnContent["queryString"] = duplicate(CGI.QUERY_STRING);
            returnContent["headers"] = httpRequest.headers;
            returnContent["data"] = duplicate(CGI);
            returnContent["form"] = duplicate(FORM);

            if (CGI.CONTENT_TYPE != "text/html" && CGI.CONTENT_TYPE != "application/x-www-form-urlencoded" && CGI.REQUEST_METHOD != "GET") {
                var temp = httpRequest.content;
                returnContent["rawData"] = Left(temp, rawDataMaxLength);
            } else {
                returnContent["rawData"] = JavaCast("null","");
            }

            return returnContent;
        </cfscript>

    </cffunction>

    <cffunction name="getQueryStringFromUrlScope" access="private" output="false" returntype="string">
        <cfscript>
            var result = "";

            for(var key in url) {
                result = result & key & "=" & url[key] & "&";
            }

            if (len(result)) {
                return left(result,len(result)-1);
            } else {
                return "";
            }
        </cfscript>
    </cffunction>

</cfcomponent>
