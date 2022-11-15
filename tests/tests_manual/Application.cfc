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

<cfcomponent>

    <cfscript>
        this.mappings = {
            "/nz" = expandPath("/src/nz")
        };
    </cfscript>

    <cffunction name="onRequestStart">
        <cfscript>
            variables.RAYGUNAPIKEY = "<your API key>";
        </cfscript>
    </cffunction>

    <cffunction name="onError">
        <cfargument name="Exception" required="true"/>
        <cfargument name="EventName" required="true"/>

        <cfscript>
            customUserDataStruct = {"session" = {"memberID" = "5747854", "memberFirstName" = "Kai"}, "params" = {"currentAction" = "IwasDoingThis", "justAnotherParam" = "test"}};
            customUserData = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunUserCustomData").init(customUserDataStruct);

            tags = ["coding","db","sqlfail"];

            userIdentifier = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunIdentifierMessage").init(Identifier="test@test.com",isAnonymous=false,UUID="47e432fff11",FirstName="Test",Fullname="Tester");

            raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
                apiKey = variables.RAYGUNAPIKEY,
                appVersion = "4.3.6"
            );

            result = raygun.send(issueDataStruct=arguments.Exception,userCustomData=customUserData,tags=tags,user=userIdentifier);
        </cfscript>
    </cffunction>
</cfcomponent>
