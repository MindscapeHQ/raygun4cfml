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

    <cfscript>
        variables.apiKey = "";
        variables.contentFilter = "";
        variables.appVersion = "";
    </cfscript>


    <cffunction name="init" access="public" output="false" returntype="any">

        <cfargument name="apiKey" type="string" required="yes">
        <cfargument name="contentFilter" type="RaygunContentFilter" required="no">
        <cfargument name="appVersion" type="string" required="no">

        <cfscript>
            variables.apiKey = arguments.apiKey;

            if (structKeyExists(arguments,"contentFilter"))
            {
                variables.contentFilter = arguments.contentFilter;
            }

            if (structKeyExists(arguments,"appVersion"))
            {
                variables.appVersion = arguments.appVersion;
            }

            return this;
        </cfscript>

    </cffunction>


    <cffunction name="send" access="public" output="false" returntype="struct">

        <cfargument name="issueDataStruct" type="any" required="yes">
        <cfargument name="userCustomData" type="RaygunUserCustomData" required="no">
        <cfargument name="tags" type="array" required="no">
        <cfargument name="user" type="RaygunIdentifierMessage" required="no">
        <cfargument name="groupingKey" type="string" required="no">
        <cfargument name="sendAsync" type="boolean" required="no" default="false">

        <cfscript>
            var payloadArgs = { "issueDataStruct" = arguments.issueDataStruct };

            // deal with custom data passed as an argument
            if (structKeyExists(arguments,"userCustomData") && isObject(arguments.userCustomData)) {
                payloadArgs["userCustomData"] = arguments.userCustomData;
            }

            // deal with tags passed as an argument
            if (structKeyExists(arguments,"tags") && isArray(arguments.tags))
            {
                payloadArgs["tags"]  = arguments.tags;
            }

            // deal with user identification data passed as an argument
            if (structKeyExists(arguments,"user") && isObject(arguments.user))
            {
                payloadArgs["user"] = arguments.user;
            }

            // deal with a grouping key passed as an argument
            if (structKeyExists(arguments,"groupingKey") && len(arguments.groupingKey))
            {
                payloadArgs["groupingKey"] = arguments.groupingKey;
            }

            var payload = buildPayload(argumentCollection=payloadArgs);

            if (arguments.sendAsync) {
                sendPayload(payload,arguments.sendAsync);
                return {};
            } else {
                return sendPayload(payload,arguments.sendAsync);
            }
        </cfscript>

    </cffunction>


    <cffunction name="sendAsync" access="public" output="true" returntype="void">

        <cfargument name="issueDataStruct" type="any" required="yes">
        <cfargument name="userCustomData" type="RaygunUserCustomData" required="no">
        <cfargument name="tags" type="array" required="no">
        <cfargument name="user" type="RaygunIdentifierMessage" required="no">
        <cfargument name="groupingKey" type="string" required="no">

        <cfscript>
            arguments["sendAsync"] = true;
            send(argumentCollection=arguments);
        </cfscript>

    </cffunction>


    <cffunction name="buildPayload" access="private" output="false" returntype="string">

        <cfargument name="issueDataStruct" type="any" required="yes">
        <cfargument name="userCustomData" type="RaygunUserCustomData" required="no">
        <cfargument name="tags" type="array" required="no">
        <cfargument name="user" type="RaygunIdentifierMessage" required="no">
        <cfargument name="groupingKey" type="string" required="no">

        <cfscript>
            var message = new RaygunMessage();
            var messageContent = "";
            var jSONData = "";

            // PR10: In CF10+, the passed in issueDataStruct is not editable in all cases anymore. It looks like a
            // struct, but is of a different internal data type behind the scenes. This works around that issue.
            var issueData = {};

            structAppend(issueData, arguments.issueDataStruct);

            if (not Len(variables.apiKey))
            {
                throw("API integration not valid, cannot send message to Raygun");
            }

            if (isObject(variables.contentFilter))
            {
                applyFilter(variables.contentFilter);
            }

            if (len(variables.appVersion))
            {
                issueData["appVersion"] = variables.appVersion
            }

            // deal with custom data passed as an argument
            if (structKeyExists(arguments,"userCustomData") && isObject(arguments.userCustomData))
            {
                issueData["userCustomData"] = arguments.userCustomData;
            }

            // deal with tags passed as an argument
            if (structKeyExists(arguments,"tags") && isArray(arguments.tags))
            {
                issueData["tags"] = arguments.tags;
            }

            // deal with user identification data passed as an argument
            if (structKeyExists(arguments,"user") && isObject(arguments.user))
            {
                issueData["user"] = arguments.user;
            }

            // deal with a grouping key passed as an argument
            if (structKeyExists(arguments,"groupingKey") && len(arguments.groupingKey))
            {
                issueData["groupingKey"] = arguments.groupingKey;
            }

            messageContent = message.build(duplicate(issueData));
            jSONData = serializeJSON(messageContent);

            // Remove '//' in case CF is adding it when serializing JSON (which is recommended in the CF Lockdown Guide)
            // KK: This will only work if the users has setup none or the default prefix for JSON data
            jSONData = ReplaceNoCase(trim(jSONData), "//{", "{");
            jSONData = ReplaceNoCase(trim(jSONData), "//[", "[");

            return jSONData;
        </cfscript>

    </cffunction>


    <cffunction name="sendPayload" access="private" output="false" returntype="any">

        <cfargument name="jsonData" type="string" required="yes">
        <cfargument name="sendAsync" type="boolean" required="no" default="false">

        <cfscript>
            var postResult = "";

            // Fixing a CF 9 issue with JVM security providers
            var needsHTTPSecurityHack = new RaygunInternalTools().needsHTTPSecurityProviderHack();

            // Fixing a CF 9 issue with JVM security providers
            if (needsHTTPSecurityHack) {
                var objSecurity = createObject("java", "java.security.Security");
                var storeProvider = objSecurity.getProvider("JsafeJCE");
                objSecurity.removeProvider("JsafeJCE");
            }
        </cfscript>

        <cfif arguments.sendAsync>
            <cfthread action="run" name="sendAsyncToRaygunThead_#createUUID()#" apiKey="#variables.apiKey#" payload="#arguments.jsonData#">
                <cftry>
                    <cfhttp url="https://api.raygun.com/entries" method="post" charset="utf-8" throwOnError="true">
                        <cfhttpparam type="header" name="Content-Type" value="application/json"/>
                        <cfhttpparam type="header" name="X-ApiKey" value="#attributes.apiKey#"/>
                        <cfhttpparam type="body" value="#attributes.payload#"/>
                    </cfhttp>
                <cfcatch type="any">
                    <cflog text="Error when trying to send to Raygun async: #serializeJSON(cfcatch)#" file="raygun" type="error">
                </cfcatch>
                </cftry>
            </cfthread>
        <cfelse>
            <cfhttp url="https://api.raygun.com/entries" method="post" charset="utf-8" result="postResult">
                <cfhttpparam type="header" name="Content-Type" value="application/json"/>
                <cfhttpparam type="header" name="X-ApiKey" value="#variables.apiKey#"/>
                <cfhttpparam type="body" value="#arguments.jSONData#"/>
            </cfhttp>
        </cfif>

        <cfscript>
            // Fixing a CF 9 issue with JVM security providers
            if (needsHTTPSecurityHack) {
                objSecurity.insertProviderAt(storeProvider, 1);
            }
        </cfscript>

        <cfreturn postResult>
    </cffunction>


    <cffunction name="applyFilter" access="private" output="false" returntype="void">

        <cfargument name="contentFilter" type="RaygunContentFilter" required="yes">

        <cfscript>
            var defaultScopes = [url,form];
            var filter = arguments.contentFilter.getFilter();
            var match = {};
            var matchResult = "";

            for (var i=1; i<=ArrayLen(filter); i++)
            {
                // current filter object (filter,replacement)
                match = filter[i];

                // loop over scopes
                for (var j=1; j<=ArrayLen(defaultScopes); j++)
                {
                    // for each scope loop over keys
                    for (var key in defaultScopes[j])
                    {
                        matchResult = reMatchNoCase(match.filter,key);

                        if (isArray(matchResult) && ArrayLen(matchResult))
                        {
                            defaultScopes[j][key] = match.replacement;
                        }
                    }
                }
            }
        </cfscript>

    </cffunction>

</cfcomponent>
