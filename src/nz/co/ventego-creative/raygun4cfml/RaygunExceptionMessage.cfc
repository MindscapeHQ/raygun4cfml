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

            var stackTraceData = [];
            var stackTraceLines = [];
            var tagContextData = [];
            var stackTraceLineElements = [];
            var stackTraceLineElement = {};
            var lenStackTraceLines = 0;
            var lenTagContext = 0;
            var j = 0;

            var isLucee = new RaygunInternalTools().isLucee();
            var isACF2021 = new RaygunInternalTools().isACF2021();

            var entryPoint = arguments.issueDataStruct;

            if (StructKeyExists(arguments.issueDataStruct,"Cause") && StructKeyExists(arguments.issueDataStruct.cause,"CatchBlock")) {
                entryPoint = arguments.issueDataStruct.cause.CatchBlock;
            }

            if (isArray(entryPoint.stacktrace)) {
                stackTraceData = entryPoint.stacktrace;
            } else if (isSimpleValue(entryPoint.stacktrace)) {
                stackTraceLines = entryPoint.stacktrace.split("\sat");
                lenStackTraceLines = ArrayLen(stackTraceLines);

                for (j=2;j<=lenStackTraceLines;j++)
                {
                    stackTraceLineElements = stackTraceLines[j].split("\(");

                    if (ArrayLen(stackTraceLineElements) == 2) {

                        stackTraceLineElement = {};
                        stackTraceLineElement["methodName"] = Trim(ListLast(stackTraceLineElements[1],"."));
                        stackTraceLineElement["className"] = Trim(ListDeleteAt(stackTraceLineElements[1],ListLen(stackTraceLineElements[1],"."),"."));
                        // PR 26 - It seems there are Java Strack Traces without line numbers
                        // Check if a line number is present in the Java Stack Trace
                        // We look for a colon followed by number(s)
                        // If no line number, return 0 so it's apparent none was given.
                        if (ReFind("\:(?!\D+)",stackTraceLineElements[2])){
                            stackTraceLineElement["fileName"] = Trim(ReReplace(stackTraceLineElements[2].split("\:(?!\D+)")[1],"[\)\n\r]",""));
                            stackTraceLineElement["lineNumber"] = Trim(ReReplace(stackTraceLineElements[2].split("\:(?!\D+)")[2],"[\)\n\r]",""));
                        }
                        else
                        {
                            stackTraceLineElement["fileName"] = Trim(ReReplace(stackTraceLineElements[2],"[\)\n\r]",""));
                            stackTraceLineElement["lineNumber"] = 0;
                        }

                        ArrayAppend(stackTraceData, stackTraceLineElement);
                    }
                }
            }

            if (structKeyExists(entryPoint,"tagcontext")) {
                lenTagContext = arraylen(entryPoint.tagcontext);

                for (j=1;j<=lenTagContext;j++)
                {
                    tagContextData[j] = {};
                    tagContextData[j]["methodName"] = "";
                    tagContextData[j]["className"] = trim( entryPoint.tagcontext[j]["id"] );
                    tagContextData[j]["fileName"] = trim( entryPoint.tagcontext[j]["template"] );
                    tagContextData[j]["lineNumber"] = trim( entryPoint.tagcontext[j]["line"] );
                }
            }

            returnContent["data"] = {"JavaStrackTrace" = stackTraceData};
            returnContent["stackTrace"] = tagContextData;

            // if we deal with an error struct, there'll be a root cause
            if (StructKeyExists(entryPoint,"RootCause")) {
                if (StructKeyExists(entryPoint["RootCause"],"Type") and entryPoint["RootCause"]["Type"] eq "expression")
                {
                    returnContent["data"]["type"] = entryPoint["RootCause"]["Type"];
                }
                if (StructKeyExists(entryPoint["RootCause"],"Message"))
                {
                    returnContent["message"] = entryPoint["RootCause"]["Message"];
                }
                returnContent["catchingMethod"] = "Error struct";
            } else {
                // otherwise there's no root cause and the specific data has to be grabbed from somewhere else
                if (!isLucee || isACF2021) {
                    returnContent["data"]["type"] = entryPoint.type;
                }
                returnContent["message"] = entryPoint.message;
                returnContent["catchingMethod"] = "CFCatch struct";
            }

            returnContent["className"] = trim( entryPoint.type );

            return returnContent;
        </cfscript>

    </cffunction>

</cfcomponent>
