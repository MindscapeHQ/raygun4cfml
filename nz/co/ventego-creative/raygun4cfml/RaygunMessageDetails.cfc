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
			var messageErrorDetails = createObject("component", "RaygunExceptionMessage").init();
			var messageRequestDetails = createObject("component", "RaygunRequestMessage").init();
			var messageClientDetails = createObject("component", "RaygunClientMessage").init();
			var messageEnvironmentDetails = createObject("component", "RaygunEnvironmentMessage").init();

			returnContent["version"] = JavaCast("null","");

            try
            {
                returnContent["machineName"] = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostAddress();
            }
            catch (any e)
            {
                returnContent["machineName"] = CGI.SERVER_NAME;
            }

			returnContent["error"] = messageErrorDetails.build(arguments.issueDataStruct);
			returnContent["request"] = messageRequestDetails.build(arguments.issueDataStruct);
			returnContent["client"] = messageClientDetails.build();
			returnContent["environment"] = messageEnvironmentDetails.build();
			returnContent["userCustomData"] = JavaCast("null","");
			returnContent["tags"] = JavaCast("null","");

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
