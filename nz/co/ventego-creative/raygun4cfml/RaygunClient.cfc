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
        variables.customRequestData = "";
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfargument name="apiKey" type="string" required="yes">
        <cfargument name="contentFilter" type="RaygunContentFilter" required="no">
        <cfargument name="customRequestData" type="RaygunCustomData" required="no">

		<cfscript>
			variables.apiKey = arguments.apiKey;

            if (structKeyExists(arguments,"contentFilter"))
            {
                variables.contentFilter = arguments.contentFilter;
            }

            if (structKeyExists(arguments,"customRequestData"))
            {
                variables.customRequestData = arguments.customRequestData;
            }

			return this;
		</cfscript>

	</cffunction>

	<cffunction name="send" access="public" output="false" returntype="struct">

		<cfargument name="issueDataStruct" type="any" required="yes">

		<cfscript>
			var message = CreateObject("component", "RaygunMessage").init();
			var messageContent = "";
			var jSONData = "";
			var postResult = "";
			// PR10: In CF10, the passed in issueDataStruct is not editable in all cases anymore. It looks like a
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

            if (isObject(variables.customRequestData))
            {
                issueData["customRequestData"] = variables.customRequestData;
            }

            messageContent = message.build(duplicate(issueData));
			jSONData = serializeJSON(messageContent);
		</cfscript>

		<cfhttp url="https://api.raygun.io/entries" method="post" charset="utf-8" result="postResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json"/>
			<cfhttpparam type="header" name="X-ApiKey" value="#variables.apiKey#"/>
			<cfhttpparam type="body" value="#jSONData#"/>
		</cfhttp>

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