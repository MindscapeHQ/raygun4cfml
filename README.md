Raygun4CFML
===========

CFML client library for [Raygun Crash Reporting](https://raygun.com).

**Current Version:** 3.0.0

**Supported Platforms:**

- Adobe ColdFusion 2021+
- Lucee 5.3+
- BoxLang 1+

## Active Development

3.0.0 adds breadcrumbs, onBeforeSend hooks, ignore exceptions, wildcard content filtering, payload size enforcement, configurable API endpoint/timeout, automatic retry, and additional environment fields — plus numerous bug fixes and 160 test specs across 11 engines.

Please be aware that no testing and work has *yet* gone into framework-specific crash reports, e.g. a deeper integration with Coldbox HMVC, Fusebox, CF on Wheels etc. This will be added over time in future releases.

## Installation

### Using CommandBox (Preferred Method)

1. **Install via CommandBox:**

   To install the latest version from the master repository, use:
   ```
   box install raygun4cfml
   ```

   To install a specific release or tag, use:
   ```
   box install git://github.com/MindscapeHQ/raygun4cfml.git#{tagname}
   ```

   Alternatively, you can use:
   ```
   box install MindscapeHQ/raygun4cfml#{tagname}
   ```

2. **Setup:**

   After installation, follow the setup instructions in the 'Library Usage' section below.

### Manual Installation

1. **Clone or Download:**

   - Fork and clone the repository to your local system, or download a zip file of the current content or a specific release/tag.

2. **Move Files:**

   - Move the `src` and/or `tests` directories to locations suitable for your system.

3. **Dependencies:**

   - Note that manual installation will not automatically resolve dependencies.

## Quick Start

```cfml
raygun = new com.raygun.RaygunClient(apiKey = "YOUR_API_KEY");

try {
    // your application code
    result = 14 / 0;
} catch (any e) {
    raygun.send(e);
}
```

Place the contents of `/src` in your webroot, or create a mapping to `/com` in your server administrator or through code.

## Library Usage

### RaygunClient

The `RaygunClient` is the primary component for sending error reports to Raygun.

#### init()

```cfml
raygun = new com.raygun.RaygunClient(
    apiKey           = "YOUR_API_KEY",
    contentFilter    = contentFilterInstance,  // optional RaygunContentFilter
    appVersion       = "1.2.3",               // optional application version string
    settings         = settingsInstance,       // optional RaygunSettings
    onBeforeSend     = callbackClosure,        // optional closure to inspect/mutate/cancel payloads
    ignoreExceptions = ["MissingInclude"]      // optional array of exception types to skip
);
```

#### send()

Sends an error report to Raygun synchronously and returns the `cfhttp` result struct.

```cfml
result = raygun.send(
    issueData      = cfcatchOrException,          // required - cfcatch/exception struct
    userCustomData = raygunUserCustomDataInstance, // optional
    tags           = ["tag1", "tag2"],             // optional array of strings
    user           = raygunIdentifierMessage,      // optional RaygunIdentifierMessage
    groupingKey    = "my-custom-grouping-key",     // optional string
    sendAsync      = false                         // optional, default false
);
```

The `issueData` argument accepts `cfcatch` or exception structs. These structs are expected to contain fields like `message`, `type`, `stacktrace`, and `tagcontext`.

#### sendAsync()

Convenience wrapper that calls `send()` with `sendAsync=true`. Returns `void`. Failures are logged to the `Raygun4CFML` log file.

```cfml
raygun.sendAsync(
    issueData      = cfcatchOrException,
    userCustomData = customData,
    tags           = ["async", "background"],
    user           = userIdentifier,
    groupingKey    = "my-grouping-key"
);
```

---

### Breadcrumbs

Record a trail of events leading up to an error. Breadcrumbs are automatically included in subsequent `send()`/`sendAsync()` calls.

```cfml
raygun = new com.raygun.RaygunClient(apiKey = "YOUR_API_KEY");

// Record breadcrumbs as your application executes
raygun.recordBreadcrumb(message = "User logged in");
raygun.recordBreadcrumb(
    message    = "Query executed",
    level      = "debug",        // debug, info, warning, error (default: info)
    category   = "database",
    className  = "UserDAO",
    methodName = "findById",
    lineNumber = 42,
    customData = {"sql": "SELECT * FROM users WHERE id = ?"}
);
raygun.recordBreadcrumb(message = "Page rendered", level = "info");

// Breadcrumbs are included when an error is sent
try {
    // application code
} catch (any e) {
    raygun.send(e);
}

// Clear breadcrumbs after sending if needed
raygun.clearBreadcrumbs();
```

The `recordBreadcrumb()` method returns `this` for chaining:

```cfml
raygun
    .recordBreadcrumb(message = "Step 1")
    .recordBreadcrumb(message = "Step 2")
    .recordBreadcrumb(message = "Step 3");
```

---

### onBeforeSend Hook

Register a callback to inspect, mutate, or cancel payloads before they are sent to Raygun.

```cfml
// Cancel sending for specific error types
raygun = new com.raygun.RaygunClient(
    apiKey = "YOUR_API_KEY",
    onBeforeSend = function(payload) {
        // Return false to cancel sending
        if (payload.details.error.className == "AbortException") {
            return false;
        }
        // Return the (optionally modified) payload to proceed
        return payload;
    }
);
```

The callback receives the full deserialized payload struct. Return `false` to cancel, return a struct to send the (optionally modified) payload, or throw an exception to proceed with the original payload.

You can also set the callback after construction:

```cfml
raygun.setOnBeforeSend(function(payload) {
    payload.details.tags.append("extra-tag");
    return payload;
});
```

---

### Ignore Exceptions

Skip sending specific exception types entirely:

```cfml
raygun = new com.raygun.RaygunClient(
    apiKey           = "YOUR_API_KEY",
    ignoreExceptions = ["MissingInclude", "AbortException", "LockTimeout"]
);
```

Matching is case-insensitive. Ignored exceptions cause `send()` to return an empty string without building or transmitting the payload. You can update the list at any time via `setIgnoreExceptions()`.

---

### RaygunSettings

Controls client behavior including raw data capture, HTTP status codes, API endpoint, timeout, and retry settings.

```cfml
settings = new com.raygun.environment.RaygunSettings(
    rawDataMaxLength = 10000,                              // default: 4096
    statusCode       = 418,                                // default: 500
    apiEndpoint      = "https://custom.example.com/entries", // default: Raygun API
    httpTimeout      = 30,                                 // default: 10 (seconds)
    maxRetries       = 3,                                  // default: 2
    retryDelay       = 2                                   // default: 1 (seconds)
);

raygun = new com.raygun.RaygunClient(
    apiKey   = "YOUR_API_KEY",
    settings = settings
);
```

| Setting | Type | Default | Description |
|---|---|---|---|
| `rawDataMaxLength` | numeric | `4096` | Maximum characters of raw request body to capture |
| `statusCode` | numeric | `500` | Default HTTP status code (auto-overridden to 404 for `MissingInclude`) |
| `apiEndpoint` | string | `https://api.raygun.com/entries` | Raygun API endpoint URL |
| `httpTimeout` | numeric | `10` | HTTP request timeout in seconds |
| `maxRetries` | numeric | `2` | Maximum retry attempts after initial failure (0 to disable) |
| `retryDelay` | numeric | `1` | Delay in seconds between retry attempts |

---

### RaygunContentFilter

Protects sensitive data from being sent to Raygun. Accepts an array of filter rules, each with a `filter` (field name or glob pattern to match) and a `replacement` (value to substitute). Filters are applied against both top-level payload keys and JSON content inside `rawData`.

**Exact match:**

```cfml
contentFilter = new com.raygun.filter.RaygunContentFilter([
    {filter: "password", replacement: "[FILTERED]"},
    {filter: "creditCard", replacement: "[FILTERED]"}
]);
```

**Wildcard patterns** (using `*` as a glob):

```cfml
contentFilter = new com.raygun.filter.RaygunContentFilter([
    {filter: "pass*", replacement: "[FILTERED]"},      // matches password, passphrase, passCode
    {filter: "*token", replacement: "[FILTERED]"},     // matches authToken, refreshToken
    {filter: "*secret*", replacement: "[FILTERED]"}    // matches mySecretKey, topSecret123
]);
```

Wildcard matching is case-insensitive and works on nested structs and rawData JSON.

```cfml
raygun = new com.raygun.RaygunClient(
    apiKey        = "YOUR_API_KEY",
    contentFilter = contentFilter
);
```

---

### RaygunUserCustomData

Attach arbitrary diagnostic data to error reports. This data appears in Raygun's **Custom Data** tab.

**Using the constructor:**

```cfml
customData = new com.raygun.user.RaygunUserCustomData(
    userCustomData = {
        "session": {"memberID": "12345", "plan": "pro"},
        "params": {"currentAction": "checkout"}
    }
);
```

**Using the builder pattern:**

```cfml
customData = new com.raygun.user.RaygunUserCustomData();
customData.add("sessionID", "abc-123");
customData.add("lastAction", "checkout");
customData.add("cartItems", 3);
```

---

### RaygunIdentifierMessage

Track affected users. All fields are optional.

| Field | Type | Description |
|---|---|---|
| `identifier` | string | Unique user identifier (e.g. email, user ID) |
| `isAnonymous` | boolean | Whether the user is anonymous (default: `true`) |
| `email` | string | User's email address |
| `fullName` | string | User's full name |
| `firstName` | string | User's first name |
| `uuid` | string | Unique identifier / session ID |

**Using the builder pattern (recommended):**

```cfml
user = new com.raygun.message.RaygunIdentifierMessage()
    .setIdentifier("user@example.com")
    .setIsAnonymous(false)
    .setEmail("user@example.com")
    .setFullName("Jane Smith")
    .setFirstName("Jane")
    .setUuid("550e8400-e29b-41d4-a716-446655440000");
```

**Using the constructor:**

```cfml
user = new com.raygun.message.RaygunIdentifierMessage(
    identifier  = "user@example.com",
    isAnonymous = false,
    email       = "user@example.com",
    fullName    = "Jane Smith",
    firstName   = "Jane",
    uuid        = "550e8400-e29b-41d4-a716-446655440000"
);
```

---

### Full Example (Application.cfc onError)

```cfml
component {

    this.name = "MyApp";

    public void function onError(required any exception, required string eventName) {

        // Custom diagnostic data
        var customData = new com.raygun.user.RaygunUserCustomData();
        customData.add("sessionID", session.sessionID);
        customData.add("currentAction", cgi.SCRIPT_NAME);

        // Tags for filtering in the Raygun dashboard
        var tags = ["onError", "production", "unhandled exception"];

        // User identification
        var user = new com.raygun.message.RaygunIdentifierMessage()
            .setIdentifier(session.userEmail)
            .setIsAnonymous(false)
            .setFullName(session.userFullName);

        // Content filtering with wildcards to protect sensitive data
        var contentFilter = new com.raygun.filter.RaygunContentFilter([
            {filter: "pass*", replacement: "[FILTERED]"},
            {filter: "*token", replacement: "[FILTERED]"},
            {filter: "creditCard", replacement: "[FILTERED]"},
            {filter: "ssn", replacement: "[FILTERED]"}
        ]);

        // Custom settings with retry and timeout
        var settings = new com.raygun.environment.RaygunSettings(
            rawDataMaxLength = 10000,
            httpTimeout      = 15,
            maxRetries       = 3
        );

        // Initialize with hooks and ignore list
        var raygun = new com.raygun.RaygunClient(
            apiKey           = "YOUR_API_KEY",
            appVersion       = "1.0.0",
            contentFilter    = contentFilter,
            settings         = settings,
            ignoreExceptions = ["AbortException"]
        );

        // Record breadcrumbs for context
        raygun.recordBreadcrumb(message = "Error handler triggered", level = "error");

        raygun.send(
            issueData      = arguments.exception,
            userCustomData = customData,
            tags           = tags,
            user           = user
        );
    }

}
```

## Automatically Captured Data

The following data is captured automatically with every error report — no additional configuration required.

**Request:**
- URL (host, script name, path info)
- HTTP method
- Query string
- Request headers
- CGI scope
- Form data (FORM scope, values truncated to 256 characters)
- URL parameters (URL scope)
- Client IP address
- Raw request body (truncated to `rawDataMaxLength`, default 4096 characters; only for non-GET requests with non-form content types)

**Environment:**
- Operating system name and version
- System architecture
- JVM vendor, version, and runtime name
- Heap memory (available and total)
- Physical memory (available and total, where accessible)
- CFML engine and version (e.g. "Lucee 6.1.0.243", "BoxLang 1.0.0")
- Processor count
- System locale
- UTC offset (hours)

**Response:**
- HTTP status code (default 500, configurable via `RaygunSettings`)
- HTTP status description
- Automatic 404 status for `MissingInclude` exceptions

**Error:**
- Error message and type
- Stack trace (parsed from Java stack trace string)
- Tag context (CFML file/line references, with code snippets on Lucee and BoxLang)
- Error code and extended info (where available)
- Nested/chained exceptions (via `cause` field)
- Database error details: SQL, query error, native error code, SQL state (for `database` type exceptions)

**Payload Safety:**
- Total payload automatically capped at 128KB
- Oversized payloads are reduced by progressively stripping expendable fields

## Samples

The `/samples` directory contains working examples for common integration patterns:

| Directory | Description |
|---|---|
| `samples/try-catch/` | Simple try/catch error reporting in a standalone script |
| `samples/app-cfc-no-filter/` | Application.cfc global error handler with user data, tags, and user identification |
| `samples/app-cfc-content-filter/` | Application.cfc with content filtering to protect sensitive fields |
| `samples/app-cfc-settings/` | Application.cfc with custom `RaygunSettings` (raw data length, status code) |
| `samples/datasources-and-sql/` | Database error reporting with SQL exception details |

### Configuring the API Key for Samples

The samples load the Raygun API key automatically — no need to edit each file. The key is resolved in this order:

1. **Local config file** — `samples/.env.json` (recommended for local development)
2. **Environment variable** — `RAYGUN_API_KEY`
3. **Placeholder** — falls back to `<YOUR API KEY>` if neither is set

**Option 1: Local config file**

Copy the template and add your key:

```bash
cp samples/.env.json.sample samples/.env.json
```

Then edit `samples/.env.json`:

```json
{
    "RAYGUN_API_KEY": "your-api-key-here"
}
```

This file is gitignored and will not be committed.

**Option 2: Environment variable**

```bash
export RAYGUN_API_KEY="your-api-key-here"
```

Or pass it when starting a CommandBox server:

```bash
RAYGUN_API_KEY="your-api-key-here" box server start serverConfigFile=server-lucee-6-1.json
```

## Development & Testing

### Dependencies

- [TestBox](https://www.ortussolutions.com/products/testbox) (dev dependency, installed via CommandBox)

### Setup

```
box install
```

### Formatting

```
box run-script format          # format all source files
box run-script format:check    # check formatting without modifying files
```

### Running Tests

```bash
./run-tests.sh server-lucee-6-1.json    # single engine
./run-tests.sh                           # all 11 engines sequentially
box run-script test                      # shortcut: Lucee 6.1
box run-script test:all                  # shortcut: all engines
```

### Available Test Servers

| Server Config | Engine | Port |
|---|---|---|
| `server-lucee-5-3.json` | Lucee 5.3 | 9196 |
| `server-lucee-5-4.json` | Lucee 5.4 | 9191 |
| `server-lucee-6-0.json` | Lucee 6.0 | 9194 |
| `server-lucee-6-1.json` | Lucee 6.1 | 9195 |
| `server-lucee-6-2.json` | Lucee 6.2 | 9199 |
| `server-lucee-7-0.json` | Lucee 7.0 | 9200 |
| `server-lucee-7-1.json` | Lucee 7.1 | 9201 |
| `server-adobe-2021.json` | Adobe ColdFusion 2021 | 9192 |
| `server-adobe-2023.json` | Adobe ColdFusion 2023 | 9193 |
| `server-adobe-2025.json` | Adobe ColdFusion 2025 | 9198 |
| `server-boxlang-1.json` | BoxLang 1 | 9197 |

## Version History

For detailed version history, refer to the [CHANGELOG.md](CHANGELOG.md).

## Contribution Guidelines

Raygun4CFML is not an official Raygun library and is not maintained by Raygun staff.

Contributions are welcome! Here's how:

1. Fork the main repository at https://github.com/MindscapeHQ/raygun4cfml
2. Create a feature branch for your changes
3. Run the formatter before submitting: `box run-script format`
4. Add or update tests for any behavior changes
5. Update README.md and CHANGELOG.md for public API changes
6. Submit a pull request

Coordination via X ([@AgentK](https://x.com/AgentK)) or GitHub ([@TheRealAgentK](https://github.com/TheRealAgentK/)) is encouraged before starting any work.

For more active development, visit the development fork at https://github.com/TheRealAgentK/raygun4cfml.

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)
