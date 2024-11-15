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
            
            try {
                var httpRequest = getHttpRequestData();
            }  catch (any e) {
                var httpRequest = {};
            }

            try {
                var localCGI = duplicate(CGI);
            }  catch (any e) {
                var localCGI = {};
            }

            try {
                var localForm = duplicate(FORM);
            }  catch (any e) {
                var localForm = {};
            }

            returnContent["hostName"] =  (localCGI.keyExists("HTTP_HOST") ? localCGI.HTTP_HOST : JavaCast("null", ""));
            returnContent["url"] = (localCGI.keyExists("SCRIPT_NAME") ? localCGI.SCRIPT_NAME : JavaCast("null", "")) & (localCGI.keyExists("PATH_INFO") ? localCGI.PATH_INFO : JavaCast("null", ""));
            returnContent["httpMethod"] = (localCGI.keyExists("REQUEST_METHOD") ? localCGI.REQUEST_METHOD : JavaCast("null", ""));    
            returnContent["iPAddress"] = (localCGI.keyExists("REMOTE_ADDR") ? localCGI.REMOTE_ADDR : JavaCast("null", ""));
            returnContent["queryString"] = (localCGI.keyExists("QUERY_STRING") ? localCGI.QUERY_STRING : JavaCast("null", ""));
            returnContent["headers"] = (httpRequest.keyExists("headers") ? httpRequest.headers : JavaCast("null", ""));
            returnContent["data"] = localCGI;
            returnContent["form"] = localForm;

            if (localCGI.keyExists("CONTENT_TYPE") && localCGI.keyExists("REQUEST_METHOD") && localCGI.CONTENT_TYPE != "text/html" && localCGI.CONTENT_TYPE != "application/x-www-form-urlencoded" && localCGI.REQUEST_METHOD != "GET") {
                returnContent["rawData"] = Left((httpRequest.keyExists("content") ? httpRequest.content : JavaCast("null", "")), rawDataMaxLength);
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
