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
		variables.userCustomData = {};
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfargument name="userCustomData" type="struct" required="yes">

		<cfscript>
			variables.userCustomData = arguments.userCustomData;

			return this;
		</cfscript>

	</cffunction>
	
	<cffunction name="getUserCustomData" access="private" output="false" returntype="struct">

		<cfreturn variables.userCustomData>

	</cffunction>

	<cffunction name="build" access="public" output="false" returntype="struct">
		
		<cfscript>
			return getUserCustomData();
		</cfscript>
	
	</cffunction>

</cfcomponent>