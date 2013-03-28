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

<cfscript>
    // This is an example for using Raygun.io in a global error handler template,
    // e.g. cferror or a template that's hooked into the ColdFusion Administrator

	// 1. With content filter
    //
    // The actual filter is an array of structs containing two properties: filer, replacement
    // filter: regExp to find key in URL or FORM scopes
    // replacement: replaccement value for the key's value
    //
    // Sample with filter (error is the CF error structure provided to the error template(s), YOURAPIKEYHERE is the Raygun.io API key)
    //
	// filter = [{filter="password",replacement="__password__"},{filter="creditcard",replacement="__ccnumber__"}];
    // contentFilter = createObject("nz.co.ventego-creative.raygun4cfml.RaygunContentFilter").init(filter);
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init("YOURAPIKEYHERE",contentFilter);
	// result = raygun.send(error)

    // 2. No content filter
    //
    // Sample without filter (error is the CF error structure provided to the error template(s), YOURAPIKEYHERE is the Raygun.io API key)
    //
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init("YOURAPIKEYHERE");
	// result = raygun.send(error)

    raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init("YOURAPIKEYHERE");
	result = raygun.send(error);
</cfscript>


