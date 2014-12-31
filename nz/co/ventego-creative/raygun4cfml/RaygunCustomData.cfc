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
		variables.session = {};
		variables.params = {};
		variables.customData = {};
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfargument name="customData" type="struct" required="no" default="#structNew()#">

		<cfscript>

			// for backwards compatibility
			if (structKeyExists(arguments,"params"))
				variables.params = arguments.params;
			if (structKeyExists(arguments,"session"))
				variables.session = arguments.session;

			variables.customData = arguments.customData;

			return this;
		</cfscript>

	</cffunction>

    <cffunction name="getSession" access="public" output="false" returntype="struct">

        <cfreturn variables.session>

    </cffunction>

    <cffunction name="getParams" access="public" output="false" returntype="struct">

        <cfreturn variables.params>

    </cffunction>

	<cffunction name="getCustomData" access="public" output="false" returntype="struct">

		<cfreturn variables.customData>

	</cffunction>

	<cffunction name="build" access="public" output="false" returntype="struct">
		<cfscript>

			var structRepresentation = getCustomData();

			if (StructCount(getSession()))
				structRepresentation["session"] = getSession();

			if (StructCount(getParams()))
				structRepresentation["params"] = getParams();

			return structRepresentation;

		</cfscript>
	</cffunction>

</cfcomponent>