<!---
Copyright 2014 Kai Koenig, Ventego Creative Ltd

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

	<cffunction name="needsHTTPSecurityProviderHack" access="public" output="false" returntype="boolean">

		<cfscript>

			var productCheck = createObject("component","nz.co.ventego-creative.tools.ProductCheck").getServerProductInfo();

			if (structCount(productCheck) && productCheck.cf_server == "ACF" && productCheck.server_main_version == 9 && ListFindNoCase("Developer,Enterprise",productCheck.product_level)) {
				return true;
			}

			return false;
		</cfscript>


	</cffunction>




</cfcomponent>
