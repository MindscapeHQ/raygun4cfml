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
		variables.filter = [];
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfargument name="filter" type="array" required="yes">

		<cfscript>
			variables.filter = arguments.filter;

			return this;
		</cfscript>

	</cffunction>

    <cffunction name="getFilter" access="public" output="false" returntype="array">

        <cfreturn variables.filter>

    </cffunction>


</cfcomponent>