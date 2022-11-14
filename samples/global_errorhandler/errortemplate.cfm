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

<cfscript>
    // This is a set of examples for using Raygun.io in a global error handler template,
    // e.g. cferror or a template that's hooked into the ColdFusion Administrator

	// 1. Using a content filter
    //
    // The actual filter is an array of structs containing two properties: filter, replacement
    // filter: regExp to find key in URL or FORM scopes
    // replacement: replacement value for the key's value
    //
    // Sample with filter (error is the CF error structure provided to the error template(s), variables.RAYGUNAPIKEY is the Raygun.io API key)
    //
	// filter = [{filter = "password", replacement = "__password__"}, {filter = "creditcard", replacement = "__ccnumber__"}];
    // contentFilter = createObject("nz.co.ventego-creative.raygun4cfml.RaygunContentFilter").init(filter);
    //
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
    //      apiKey =  variables.RAYGUNAPIKEY,
    //      contentFilter = contentFilter
    // );
    //
	// result = raygun.send(error)



    // 2. No content filter
    //
    // Sample without filter (error is the CF error structure provided to the error template(s), variables.RAYGUNAPIKEY is the Raygun.io API key)
    //
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
    //      apiKey =  variables.RAYGUNAPIKEY
    // );
    //
	// result = raygun.send(error)



	// 3. Sending custom data (NEW way of doing it)
    //
    // Sample with passing in session and params data structures (error is the CF error structure provided to the error template(s), variables.RAYGUNAPIKEY is the Raygun.io API key)
    //
    // customUserDataStruct = {"session" = {"memberID" = "5747854", "memberFirstName" = "Kai"}, "params" = {"currentAction" = "IwasDoingThis", "justAnotherParam" = "test"}};
    // customUserData = createObject("nz.co.ventego-creative.raygun4cfml.RaygunUserCustomData").init(customUserDataStruct);
    //
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
    //      apiKey =  variables.RAYGUNAPIKEY
    // );
	//
	// result = raygun.send(issueDataStruct=error,userCustomData=customUserData);



	// 4. Sending tags
    //
    // Sample with passing in tags (error is the CF error structure provided to the error template(s), variables.RAYGUNAPIKEY is the Raygun.io API key)
    //
    // tags = ["coding","db","sqlfail"];
    //
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
    //      apiKey = variables.RAYGUNAPIKEY
    // );
	//
	// result = raygun.send(issueDataStruct=error,tags=tags);



	// 5. Sending user information
    //
    // Sample with passing in user information (error is the CF error structure provided to the error template(s), variables.RAYGUNAPIKEY is the Raygun.io API key)
    //
    // userIdentifier = createObject("nz.co.ventego-creative.raygun4cfml.RaygunIdentifierMessage").init(Identifier="test@test.com",isAnonymous=false,UUID="47e432fff11",FirstName="Test",Fullname="Tester");
    //
    // raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
    //      apiKey = variables.RAYGUNAPIKEY
    // );
	//
	// result = raygun.send(issueDataStruct=error,user=userIdentifier);
</cfscript>


