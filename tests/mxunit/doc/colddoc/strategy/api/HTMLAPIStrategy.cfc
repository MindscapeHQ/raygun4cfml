<!--- Hacked extends and TEMPLATE_PATH to make it run in mxunit without external dependencies --->
<cfcomponent hint="Default Document Strategy for ColdDoc" extends="mxunit.doc.colddoc.strategy.AbstractTemplateStrategy" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cfscript>
	instance.static.TEMPLATE_PATH = "/mxunit/doc/colddoc/strategy/api/resources/templates";
</cfscript>


<cffunction name="init" hint="Constructor" access="public" returntype="HTMLAPIStrategy" output="false">
	<cfargument name="outputDir" hint="the output directory" type="string" required="Yes">
	<cfargument name="projectTitle" hint="the title of the project" type="string" required="No" default="Untitled">
	<cfscript>
		super.init();

		setOutputDir(arguments.outputDir);
		setProjectTitle(arguments.projectTitle);

		return this;
	</cfscript>
</cffunction>

<cffunction name="run" hint="Run this strategy" access="public" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var basePath = getDirectoryFromPath(getMetaData(this).path);
		var args = 0;

		recursiveCopy(basePath & "resources/static", getOutputDir());

		//write the index template
		args = {path=getOutputDir() & "/index.html", template="#instance.static.TEMPLATE_PATH#/index.html", projectTitle=getProjectTitle()};
		writeTemplate(argumentCollection=args);

		writeOverviewSummaryAndFrame(arguments.qMetaData);

		writeAllClassesFrame(arguments.qMetaData);

		writePackagePages(arguments.qMetaData);
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="writePackagePages" hint="writes the package summaries" access="private" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var currentDir = 0;
		var qPackage = 0;
	</cfscript>

	<cfoutput query="arguments.qMetaData" group="package">
		<cfscript>
			currentDir = getOutputDir() & "/" & replace(package, ".", "/", "all");
			ensureDirectory(currentDir);
			qPackage = getMetaSubquery(arguments.qMetaData, "package = '#package#'", "name asc");

			writeTemplate(path=currentDir & "/package-summary.html",
						template="#instance.static.TEMPLATE_PATH#/package-summary.html",
						projectTitle = getProjectTitle(),
						package = package,
						qPackage = qPackage);

			writeTemplate(path=currentDir & "/package-frame.html",
						template="#instance.static.TEMPLATE_PATH#/package-frame.html",
						projectTitle = getProjectTitle(),
						package = package,
						qPackage = qPackage);

			buildClassPages(qPackage,
							arguments.qMetadata
							);
		</cfscript>
	</cfoutput>
</cffunction>

<cffunction name="buildClassPages" hint="builds the class pages" access="private" returntype="void" output="false">
	<cfargument name="qPackage" hint="the query for a specific package" type="query" required="Yes">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var qSubClass = 0;
		var currentDir = 0;
	</cfscript>
	<cfloop query="arguments.qPackage">
		<cfscript>
			currentDir = getOutputDir() & "/" & replace(package, ".", "/", "all");
			qSubClass = getMetaSubquery(arguments.qMetaData, "extends = '#package#.#name#'", "package asc, name asc");

			writeTemplate(path=currentDir & "/#name#.html",
						template="#instance.static.TEMPLATE_PATH#/class.html",
						projectTitle = getProjectTitle(),
						package = package,
						name = name,
						qSubClass = qSubClass,
						qMetadata = qMetaData,
						metadata = metadata
						);
		</cfscript>
	</cfloop>
</cffunction>

<cffunction name="writeOverviewSummaryAndFrame" hint="writes the overview-summary.html" access="private" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var qPackages = 0;
	</cfscript>
		<cfquery name="qPackages" dbtype="query" debug="false">
			SELECT DISTINCT
				package
			FROM
				arguments.qMetaData
			ORDER BY
				package
		</cfquery>

	<cfscript>
		writeTemplate(path=getOutputDir() & "/overview-summary.html",
					template="#instance.static.TEMPLATE_PATH#/overview-summary.html",
					projectTitle = getProjectTitle(),
					qPackages = qPackages);


		//overview frame
		writeTemplate(path=getOutputDir() & "/overview-frame.html",
					template="#instance.static.TEMPLATE_PATH#/overview-frame.html",
					projectTitle=getProjectTitle(),
					qPackages = qPackages);
	</cfscript>
</cffunction>

<cffunction name="writeAllClassesFrame" hint="writes the allclasses-frame.html" access="private" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		arguments.qMetadata = getMetaSubquery(query=arguments.qMetaData, orderby="name asc");

		writeTemplate(path=getOutputDir() & "/allclasses-frame.html",
					template="#instance.static.TEMPLATE_PATH#/allclasses-frame.html",
					qMetaData = arguments.qMetaData);
	</cfscript>
</cffunction>

<cffunction name="getOutputDir" access="private" returntype="string" output="false">
	<cfreturn instance.outputDir />
</cffunction>

<cffunction name="setOutputDir" access="private" returntype="void" output="false">
	<cfargument name="outputDir" type="string" required="true">
	<cfset instance.outputDir = arguments.outputDir />
</cffunction>

<cffunction name="getProjectTitle" access="private" returntype="string" output="false">
	<cfreturn instance.projectTitle />
</cffunction>

<cffunction name="setProjectTitle" access="private" returntype="void" output="false">
	<cfargument name="projectTitle" type="string" required="true">
	<cfset instance.projectTitle = arguments.projectTitle />
</cffunction>

</cfcomponent>