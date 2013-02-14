<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="package" output="false" returntype="struct">

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
			// TODO: This is not really nice, there should be separate fields to put stuff into
			returnContent["osVersion"] = props["os.name"] & "|" & props["os.version"];
			// TODO: This is not really nice, there should be separate fields to put stuff into
			returnContent["packageVersion"] = props["java.vm.vendor"] & "|" & props["java.runtime.version"] & "|" & props["java.vm.name"];
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
