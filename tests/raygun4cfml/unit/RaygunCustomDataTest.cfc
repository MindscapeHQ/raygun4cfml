<!---
Copyright 2013-2014 Kai Koenig, Ventego Creative Ltd

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

<cfcomponent displayname="RaygunCustomData tests" extends="testbox.system.testing.BaseSpec">

    <cffunction name="setup">
    	<cfscript>
			RaygunCustomData = CreateObject("component","nz.co.ventego-creative.raygun4cfml.RaygunCustomData");
    	</cfscript>
    </cffunction>

    <cffunction name="teardown">
    </cffunction>

    <cffunction name="beforeTests">
    </cffunction>

    <cffunction name="afterTests">
    </cffunction>

    <cffunction name="testObjectInitProperEmpty">
        <cfscript>
        	RaygunCustomData.init({},{});

            $assert.typeOf("component", RaygunCustomData );
        </cfscript>
    </cffunction>

    <cffunction name="testObjectInitFailsEmpty">
        <cfscript>
        	expectedException("Application");

        	RaygunCustomData.init();
        </cfscript>
    </cffunction>

    <cffunction name="testGetProperDataOutForPopulatedStructs">
        <cfscript>
        	var mySession = {"id"=123456,"username"="tester"};
        	var myParams = {"name"="Peter","lastname"="Miller"};
        	RaygunCustomData.init(mySession,myParams);

        	$assert.typeOf("struct",RaygunCustomData.getSession(),"Session not a struct");
        	$assert.typeOf("struct",RaygunCustomData.getParams(),"Params not a struct");

			$assert.isNotEmpty(RaygunCustomData.getSession(),"Returned Session struct is empty");
			$assert.isNotEmpty(RaygunCustomData.getParams(),"Returned Params struct is empty");

			$assert.isEqual(structCount(RaygunCustomData.getSession()),structCount(mySession),"Count in Session not equal");
		    $assert.isEqual(structCount(RaygunCustomData.getParams()),structCount(myParams),"Count in Params not equal");
        </cfscript>
    </cffunction>


</cfcomponent>
