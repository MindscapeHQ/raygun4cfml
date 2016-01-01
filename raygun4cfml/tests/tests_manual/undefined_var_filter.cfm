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

<cferror type="exception" template="../../samples/global_errorhandler/errortemplate.cfm">

<!--- This test file requires you to have a global errorhandler setup or  deal with the resulting error via cferror (see above) or onError and having a filter setup --->
<cfset form["Kai"] = 38>
<cfset form["Password"] = "gfgfdgfdgfdgfd">
<cfset form["KaisSecretPasswordThing"] = "gfgfgfdfgdw432443543">
<cfset url["myCreditcard"] = "6565654">

<cfoutput>#test1234544#</cfoutput>