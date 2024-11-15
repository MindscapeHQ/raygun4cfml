<cfscript>

customUserDataStruct = { 
	key1 = {
		password = "secret" 
	},
	key2 = {
		password = "secret"
	}
};
customUserData = createObject("nz.co.ventego-creative.raygun4cfml.RaygunUserCustomData").init(customUserDataStruct);

contentFilterArray = [{
    filter = "password", 
    replacement = "__password__"}
];
contentFilter = createObject("nz.co.ventego-creative.raygun4cfml.RaygunContentFilter").init(contentFilterArray);

raygun = createObject("component","nz.co.ventego-creative.raygun4cfml.RaygunClient").init(
     apiKey =  "<your API key>",
     contentFilter = contentFilter
);

try {
    (1/0);
} catch (any e) {
        result = raygun.send(issueDataStruct = e, userCustomData = customUserData);
}


</cfscript>