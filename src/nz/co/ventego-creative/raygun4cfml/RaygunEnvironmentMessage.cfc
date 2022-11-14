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

<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfscript>
			return this;
		</cfscript>

	</cffunction>

	<cffunction name="build" access="public" output="false" returntype="struct">

		<cfscript>
			var returnContent = {};
			var runtime = createObject("java", "java.lang.System");
			var props = runtime.getProperties();
			var mf = createObject("java", "java.lang.management.ManagementFactory");
			var heapMem = mf.getMemoryMXBean().getHeapMemoryUsage();
			var osbean = "";

			returnContent["availableVirtualMemory"] = heapMem.getCommitted()-heapMem.getUsed();
			returnContent["totalVirtualMemory"] = heapMem.getCommitted();
			returnContent["architecture"] = props["os.arch"];
			returnContent["osVersion"] = props["os.version"];
			returnContent["packageVersion"] = props["java.vm.vendor"] & "|" & props["java.runtime.version"] & "|" & props["java.vm.name"];
			returnContent["platform"] = props["os.name"];

			try {
				osbean = mf.getOperatingSystemMXBean();
				returnContent["availablePhysicalMemory"] = osbean.getFreePhysicalMemorySize();
				returnContent["totalPhysicalMemory"] = osbean.getTotalPhysicalMemorySize();
			}
			catch (any e) {
				returnContent["availablePhysicalMemory"] = JavaCast("null","");
				returnContent["totalPhysicalMemory"] = JavaCast("null","");
			}

			return returnContent;
		</cfscript>

	</cffunction>

</cfcomponent>
