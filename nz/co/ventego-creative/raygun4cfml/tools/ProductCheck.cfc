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

  	<cffunction name="getServerProductInfo" access="public" output="false" returntype="struct">

  		<cfscript>
			var stProductInfo = {};

			if (server.ColdFusion.ProductName CONTAINS "Railo") {

				  stProductInfo.cf_server = "Railo";
				  stProductInfo.server_version = listFirst(server.railo.version);

			} else if (server.ColdFusion.ProductName CONTAINS "Lucee") {

				  stProductInfo.cf_server = "Lucee";
				  stProductInfo.server_version = listFirst(server.lucee.version);

			} else if (server.ColdFusion.ProductName CONTAINS "ColdFusion") {

				  stProductInfo.cf_server = "ACF";
				  stProductInfo.server_version = server.coldfusion.productversion;
				  stProductInfo.server_main_version = ListFirst(stProductInfo.server_version);
				  stProductInfo.product_level = server.coldfusion.productlevel;

			}

			return stProductInfo;
		</cfscript>

  	</cffunction>

</cfcomponent>
