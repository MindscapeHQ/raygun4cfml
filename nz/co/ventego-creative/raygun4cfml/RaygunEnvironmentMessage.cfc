<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

		<cfargument name="issueDataStruct" type="struct" required="yes">

		<cfscript>
			var returnContent = {};

			returnContent["architecture"] = "";
			returnContent["availablePhysicalMemory"] = "";
			returnContent["availableVirtualMemory"] = "";
			returnContent["cpu"] = "";
			returnContent["currentOrientation"] = "";
			returnContent["diskSpaceFree"] = "";
			returnContent["location"] = "";
			returnContent["osVersion"] = "";
			returnContent["packageVersion"] = "";
			returnContent["processorCount"] = "";
			returnContent["resolutionScale"] = "";
			returnContent["totalPhysicalMemory"] = "";
			returnContent["totalVirtualMemory"] = "";
			returnContent["windowBoundsHeight"] = "";
			returnContent["windowBoundsWidth"] = "";

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
