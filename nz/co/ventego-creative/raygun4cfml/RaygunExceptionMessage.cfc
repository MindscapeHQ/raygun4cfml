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
			var stackTraceData = [];
			var stackTraceLines = [];
			var lenStackTraceLines = 0;
			var stackTraceLineElements = [];
			var j = 0;

			stackTraceLines = arguments.issueDataStruct.stacktrace.split("\sat");
			lenStackTraceLines = ArrayLen(stackTraceLines);

			for (j=2;j<=lenStackTraceLines;j++)
			{
				stackTraceLineElements = stackTraceLines[j].split("\(");
				stackTraceData[j-1] = {};
				stackTraceData[j-1]["methodName"] = ListLast(stackTraceLineElements[1],".");
				stackTraceData[j-1]["className"] = ListDeleteAt(stackTraceLineElements[1],ListLen(stackTraceLineElements[1],"."),".");
				stackTraceData[j-1]["fileName"] = stackTraceLineElements[2].split(":")[1];
				stackTraceData[j-1]["lineNumber"] = ReplaceNoCase(stackTraceLineElements[2].split(":")[2],")","");
			}

			returnContent["Data"] = {"TagContext" = arguments.issueDataStruct.TagContext};

			if (StructKeyExists(arguments.issueDataStruct,"RootCause"))
			{
				if (StructKeyExists(arguments.issueDataStruct["RootCause"],"Type") and arguments.issueDataStruct["RootCause"]["Type"] eq "expression")
				{
					returnContent["data"]["type"] = arguments.issueDataStruct["RootCause"]["Type"];
					returnContent["data"]["name"] = arguments.issueDataStruct["RootCause"]["Name"];
				}
			}

			returnContent["className"] = arguments.issueDataStruct.type;
			returnContent["catchingMethod"] = "error struct";
			returnContent["message"] = "";
			if (StructKeyExists(arguments.issueDataStruct,"diagnostics")) {
				returnContent["message"] = arguments.issueDataStruct.diagnostics;
			}
			returnContent["stackTrace"] = stackTraceData;
			returnContent["fileName"] = "";
			returnContent["innerError"] = "";

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>