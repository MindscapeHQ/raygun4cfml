<!---
Copyright 2015 Kai Koenig, Ventego Creative Ltd

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
		variables.Identifier = "";
		variables.IsAnonymous = "";
		variables.Email = "";
		variables.FullName = "";
		variables.FirstName = "";
		variables.UUID = "";
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfargument name="Identifier" type="string" required="yes">
		<cfargument name="IsAnonymous" type="boolean" required="no">
		<cfargument name="Email" type="string" required="no">
		<cfargument name="FullName" type="string" required="no">
		<cfargument name="FirstName" type="string" required="no">
		<cfargument name="UUID" type="string" required="no">

		<cfscript>
			variables.Identifier = arguments.Identifier;
			
			if (structKeyExists(arguments,"IsAnonymous")) {
				variables.IsAnonymous = arguments.IsAnonymous;
			}
			
			if (structKeyExists(arguments,"Email")) {
				variables.Email = arguments.Email;
			}
			
			if (structKeyExists(arguments,"FullName")) {
				variables.FullName = arguments.FullName;
			}
			
			if (structKeyExists(arguments,"FirstName")) {
				variables.FirstName = arguments.FirstName;
			}
			
			if (structKeyExists(arguments,"UUID")) {
				variables.UUID = arguments.UUID;
			}
			
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfscript>
			var returnContent = {};

			returnContent["Identifier"] = variables.Identifier;
			returnContent["IsAnonymous"] = variables.IsAnonymous;
			returnContent["Email"] = variables.Email;
			returnContent["FullName"] = variables.FullName;
			returnContent["FirstName"] = variables.FirstName;
			returnContent["UUID"] = variables.UUID;
			
			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
