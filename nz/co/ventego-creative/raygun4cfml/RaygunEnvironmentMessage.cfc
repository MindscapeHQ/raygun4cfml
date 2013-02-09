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
			var runtime = createObject("java", "java.lang.System");
			var props = runtime.getProperties();
			var mf = createObject("java", "java.lang.management.ManagementFactory");
			var osbean = mf.getOperatingSystemMXBean();

			returnContent["architecture"] = props["os.arch"];
			returnContent["availablePhysicalMemory"] = osbean.getFreePhysicalMemorySize();
			returnContent["availableVirtualMemory"] = JavaCast("null","");
			returnContent["cpu"] = JavaCast("null","");
			returnContent["currentOrientation"] = JavaCast("null","");
			returnContent["diskSpaceFree"] = JavaCast("null","");
			returnContent["deviceName"] = JavaCast("null","");
			returnContent["location"] = JavaCast("null","");
			returnContent["osVersion"] = props["os.version"];
			returnContent["packageVersion"] = JavaCast("null","");
			returnContent["processorCount"] = JavaCast("null","");
			returnContent["resolutionScale"] = JavaCast("null","");
			returnContent["totalPhysicalMemory"] = osbean.getTotalPhysicalMemorySize();
			returnContent["totalVirtualMemory"] = JavaCast("null","");
			returnContent["windowBoundsHeight"] = JavaCast("null","");
			returnContent["windowBoundsWidth"] = JavaCast("null","");

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
