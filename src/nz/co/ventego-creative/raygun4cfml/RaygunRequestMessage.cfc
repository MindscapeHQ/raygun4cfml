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

            returnContent["hostName"] = CGI.HTTP_HOST;
            returnContent["url"] = CGI.SCRIPT_NAME & CGI.PATH_INFO
            returnContent["httpMethod"] = CGI.REQUEST_METHOD;
            returnContent["iPAddress"] = CGI.REMOTE_ADDR;
            returnContent["queryString"] = CGI.QUERY_STRING;
            returnContent["headers"] = httpRequest.headers;
            returnContent["data"] = CGI;
            returnContent["form"] = FORM;

            returnContent["rawData"] = JavaCast("null", "");
            if (CGI.CONTENT_TYPE != "text/html" && CGI.CONTENT_TYPE != "application/x-www-form-urlencoded" && CGI.REQUEST_METHOD != "GET") {
                if(!isBinary(httpRequest.content)) {
                    // TODO check if this is JSON and if yes, deserialise and apply content filter in some way here and then deserialise again
                    var temp = httpRequest.content;
                    returnContent["rawData"] = Left(temp, rawDataMaxLength);
                }
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
