<cfscript>
raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
    apiKey = "<your API key>",
    contentFilter = createObject(
                    "component",
                    "nz.co.ventego-creative.raygun4cfml.RaygunContentFilter"
                ).init( [
                    {
                        filter      : "ghjdfkgdt",
                        replacement : "__hjkjkpassword__"
                    },
                    {
                        filter      : "ghjdyt767fkgdt",
                        replacement : "__hjkjkpassword__"
                    },
                    {
                        filter      : "fgdgf",
                        replacement : "__hjkjkpassword__"
                    }
                ] )
);

    try {
        (1/0);
    } catch(any e) {
        result = raygun.send(e);
    }


</cfscript>