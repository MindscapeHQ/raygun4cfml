<cfcomponent output="false" hint="I define the unit-testing application settings.">

    <!--- Define the application settings. --->
    <cfset this.name = hash( getCurrentTemplatePath() ) />
    <cfset this.applicationTimeout = createTimeSpan( 0, 0, 5, 0 ) />
    <cfset this.sessionManagement = false />

    <cfset this.directory = getDirectoryFromPath( getCurrentTemplatePath() ) />
    <cfset this.mxunitDirectory = (this.directory & "mxunit/") />
    <cfset this.appDirectory = (this.directory & "../") />

    <!---
    ***** MX UNIT FRAMEWORK *****
    Set up a mapping to the MXUnit framework; this is requied for the framework installation to run without a global mapping.
    --->
    <cfset this.mappings[ "/mxunit" ] = this.mxunitDirectory />

    <!---
    ***** APPLICATION COMPONENTS *****
    Map the component directory so we can include our application's components for unit testing.
    --->
    <cfset this.mappings[ "/" ] = this.appDirectory  />


</cfcomponent>