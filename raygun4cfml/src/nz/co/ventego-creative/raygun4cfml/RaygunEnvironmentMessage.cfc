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
