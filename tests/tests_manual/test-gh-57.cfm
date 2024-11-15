<cfscript>


thread action="run" name="myThread" {

    var raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
        apiKey = "<your API key>"
    );

    try {
        (1/0);
    } catch(any e) {
        result = raygun.send(e);
    }
}

</cfscript>