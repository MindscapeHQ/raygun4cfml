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

	<cfscript>
		variables.apiKey = "";
        variables.contentFilter = "";
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfargument name="apiKey" type="string" required="yes">
        <cfargument name="contentFilter" type="RaygunContentFilter" required="no">

		<cfscript>
			variables.apiKey = arguments.apiKey;

            if (structKeyExists(arguments,"contentFilter"))
            {
                variables.contentFilter = arguments.contentFilter;
            }

			return this;
		</cfscript>

	</cffunction>

	<cffunction name="send" access="public" output="false" returntype="struct">

		<cfargument name="issueDataStruct" type="any" required="yes">
		<cfargument name="userCustomData" type="RaygunUserCustomData" required="no">
		<cfargument name="tags" type="array" required="no">
		<cfargument name="user" type="RaygunIdentifierMessage" required="no">

		<cfscript>
			var message = CreateObject("component", "RaygunMessage").init();
			var messageContent = "";
			var jSONData = "";
			var postResult = "";

			// PR10: In CF10+, the passed in issueDataStruct is not editable in all cases anymore. It looks like a
			// struct, but is of a different internal data type behind the scenes. This works around that issue.
			var issueData = {};

			// Fixing a CF 9 issue with JVM security providers
			var needsHTTPSecurityHack = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunInternalTools").needsHTTPSecurityProviderHack();

			structAppend(issueData, arguments.issueDataStruct);

			if (not Len(variables.apiKey))
			{
				throw("API integration not valid, cannot send message to Raygun");
			}

            if (isObject(variables.contentFilter))
            {
                applyFilter(variables.contentFilter);
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
            messageContent = message.build(duplicate(issueData));
			jSONData = serializeJSON(messageContent);

            // Fixing a CF 9 issue with JVM security providers
            if (needsHTTPSecurityHack) {
                var objSecurity = createObject("java", "java.security.Security");
                var storeProvider = objSecurity.getProvider("JsafeJCE");
                objSecurity.removeProvider("JsafeJCE");
            }
		</cfscript>

        	<!---  Remove // in case CF is adding it when serializing JSON (which is recommended in the CF Lockdown Guide)  --->
        	<cfset jSONData = ReplaceNoCase(trim(jSONData), "//{", "{")>
        	<cfset jSONData = ReplaceNoCase(trim(jSONData), "//[", "[")>

		<cfhttp url="https://api.raygun.io/entries" method="post" charset="utf-8" result="postResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json"/>
			<cfhttpparam type="header" name="X-ApiKey" value="#variables.apiKey#"/>
			<cfhttpparam type="body" value="#jSONData#"/>
		</cfhttp>

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
