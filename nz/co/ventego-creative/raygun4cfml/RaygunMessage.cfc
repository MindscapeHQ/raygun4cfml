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

		<cfargument name="issueDataStruct" type="struct" required="yes">

		<cfscript>
			var returnContent = {};
			var messageDetails = CreateObject("component", "RaygunMessageDetails").init();
			var ts = DateConvert("Local2UTC",now());

			returnContent["occurredOn"] = "#DateFormat(ts,'yyyy-mm-dd')#T#timeFormat(ts,'HH:mm:ss')#Z";
			returnContent["details"] = messageDetails.build(arguments.issueDataStruct);

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>