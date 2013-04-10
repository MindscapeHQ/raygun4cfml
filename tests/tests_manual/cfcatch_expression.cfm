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

<!--- catching an exception - in this case an Expression exception --->

<cftry>
    <cfscript>
		a = 34;
		b = 0;
		c = a/b;
	</cfscript>
<cfcatch>
	<cfdump var="#cfcatch#"/>
    <cfset raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init("YOURAPIKEYHERE")/>
    <cfset result = raygun.send(cfcatch)/>
    <cfdump var="#result#"/>
</cfcatch>
</cftry>