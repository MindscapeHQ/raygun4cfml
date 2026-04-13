History and Plan
================

3.0.0-rc.1 (April 13, 2026)

New Features:

- **Breadcrumbs**: Record a trail of events leading up to an error via `recordBreadcrumb()` and `clearBreadcrumbs()`. Breadcrumbs are automatically included in subsequent `send()`/`sendAsync()` calls with timestamp, level, type, category, message, className, methodName, lineNumber, and customData fields (#46).
- **onBeforeSend hook**: Register a callback via constructor or `setOnBeforeSend()` to inspect, mutate, or cancel payloads before sending. Return `false` to cancel, return a modified struct to mutate, or throw to proceed with the original payload.
- **Ignore exceptions list**: Skip specific exception types via `ignoreExceptions` constructor argument or `setIgnoreExceptions()`. Case-insensitive matching (e.g. `["MissingInclude", "AbortException"]`).
- **Wildcard content filter keys**: `RaygunContentFilter` now supports glob-style `*` wildcards in filter patterns (e.g. `"pass*"` matches `password`, `passphrase`, `passCode`). Exact-match filters continue to work as before.
- **Payload size enforcement**: Payloads exceeding 128KB are automatically reduced by progressively stripping expendable fields (rawData, userCustomData, CGI data, headers, form). Form field values are truncated to 256 characters.
- **Configurable API endpoint**: Set a custom Raygun API endpoint via `RaygunSettings.apiEndpoint` (default: `https://api.raygun.com/entries`).
- **HTTP timeout**: All API requests now have a configurable timeout via `RaygunSettings.httpTimeout` (default: 10 seconds).
- **Automatic retry**: Failed HTTP requests are retried with configurable `RaygunSettings.maxRetries` (default: 2) and `RaygunSettings.retryDelay` (default: 1 second). Set `maxRetries=0` to disable.
- **Additional environment fields**: `processorCount`, `locale`, and `utcOffset` are now captured in every error report.
- **Sample API key configuration**: Samples now load the Raygun API key automatically from `samples/.env.json` (gitignored) or the `RAYGUN_API_KEY` environment variable — no more manual copy-paste into each file.

Bug Fixes:

- Fixed settings not propagating to RaygunRequestMessage and RaygunResponseMessage
- Fixed empty stackTrace when Java stack trace is empty but CFML tag context is available
- Fixed case-sensitive exception type checks (e.g. "database" vs "Database")
- Fixed unsafe CGI scope access in RaygunRequestMessage and RaygunMessageDetails
- Fixed sync/async HTTP error handling inconsistency in RaygunClient
- Fixed thread name typo in async sending
- Fixed typed property defaults (`default=""` on non-string typed properties)
- Added `isNull()` guards on `getSettings()`/`getContentFilter()` to prevent NPE on strict engines

Code Quality:

- Centralized all magic strings and constants in `RaygunConfig` (API endpoint, log file name, content types, HTTP methods, size limits, timeout/retry defaults)
- Replaced `isClosure()` with `isCustomFunction()` for cross-engine compatibility
- 160 test specs (up from 70), covering all components
- Added Lucee 6.2, 7.0, and 7.1 to test matrix (11 engines total)

2.1.0 (Jan 21 2025)

- Add support for response.statusCode and statusDescription (#48)

2.0.1 (Jan 13 2025)

- Fixed issue with ACF Content filtering and CGI-Scope

2.0.0 (Jan 12 2025)

- Fixed issue with Boxlang CGI-Scope
- Added Lucee 5.3 support back-in and provided test server setup

2.0.0-alpha (January 4 2025)

- Complete re-write, breaking API changes and changes in essential functionality:
    - Raygun4CFML is now entirely written in CFML script.
    - The original stack trace is now tracked in the stack trace field, not the CFML `TagContext`. The latter is now in the exception's data section, where available.
    - There is now proper support for nested exceptions (based on existence of `cause` field).
    - Content filtering (`RaygunContentFilter`), user identifier (`RaygunIdentifierMessage`) and user custom data (`RaygunUserCustomData`) are now using the builder-pattern approach to be setup for `RaygunClient`.
    - Size of raw data can be configured (#42).
    - SQL exception tracking has been improved (#44).
    - Constants are now tracked in their own static component and some can be overwritten by `RaygunSettings`.
    - `ProductCheck` and `RaygunInternalTools` are now static components.
    - CFML engine is being track in Raygun's Environment tab now.
- Samples in `/samples` have been reworked.
- Unit/Integration tests are in `/tests/specs`.
- Code formatting via `run-script format` was added for Commandbox.
- Project contains custom CFML server declarations for testing on ports (port 9191 upwards).
- All files have improved code documentation.
- Engine-specific changes:
    - Support for Adobe ColdFusion *before* ACF 2021 has been stopped. ACF 2018 and earlier are - as CFML engines go - not supported any more, please upgrade your platforms.
    - Support for any versions of Railo has been stopped. Lucee support is set to Lucee 5.4 and newer, but this might be extended to 5.3 in a future 2.0.0 pre-release.
    - Support for Boxlang 1.0.0 has been added. 

1.7.0 (November 14 2024)

- Fixes issues around non-existent HTTP request objects when run on ACF and in a thread context
- Fixes access to JVM memory beans depending on JVM settings and JVM type available
- Minimum requirements are now Lucee 5+ anmd ACF 2018+
- Fixes issue with content filter not trailing deep into payload

1.6.0 (November 23 2023)

- Fixed issue in RaygunExceptionMessage on recent version of ACF
- Changed content/sensitivity filter behaviour. It now runs just before data is being send to RG and filters against the full pre-send payload and not just URL/FORM scopes.

1.5.0 (November 14 2022)

- Added .sendAsync() entry point wrapping the HTTP call into its own thread. 
- Regorganisation of code in RaygunClient
- Improving handling of getHTTPRequestData in RaygunRequestMessage
- Changed HTTP endpoint to .com
- Supports groupingKey now

1.4.0 (May 24 2022)

- Supporting stack traces where certain elements (like TagContext) don't exist
- Support for specifc Java strack traces stemming from asynchronous handling

1.3.1 (Jul 26 2021)

- Physical memory tracking again under certain conditions, provided the underlying Java code is available on the JVM (modules opened up).

1.3.0 (Jul 21 2021)

- Raygun4CFML is now tracking heap memory in the `availableVirtualMemory` and `availableFreeMemory` fields and not physical memory anymore. Fixed accessibility issues of internal classes post-Java 8 and the library should now be working fine across all JDKs.

1.2.1 (Jun 16 2021)

- Minor changes to stacktrace handling
- Additional of Path Info to Request URL data

1.2.0 (Jun 8 2021)

- Support for version (#33)
- Fixed stack traces to work better with Lucee and ACF 2021

1.1.0 (Jan 2 2016)

- Refactored packages and file/dir locations to cater for ideas in PR28 and to prepare for Forgebox packaging
- Added Forgebox packaging
- Enhanced documentation
- Changed internal code to make the CFCs independen of package paths
- Changed internal code to instantiate CFCs using "new", therefore breaking compatibility with ACF8 (and probably Railo 3)
- From this version onwards, raygun4cfml will use semantic versioning for the version numbers (semver.org)

1.0.2.0 (Nov 14 2015):

- Merged PR26 and modified/refactored it slightly

1.0.1.0 (Nov 14 2015):

- Merged PR23 and PR24 and modified/refactored them slightly

1.0.0.1 (Jul 1 2015):

- Merged PR21 from Alex --- fixing naming inconsistencies in the user tracking object

1.0.0.0 (Jan 3 2015): 

- Support for Tags and Affected User (please check samples 4 and 5 in samples/global_errorhandler/errortemplate.cfm and the code in the tests_manual directories for samples on how to use them)
- Moves statusCode from request to details structure
- Changed the behaviour of userCustomData. Essentially removed all the old, backwards compatibility code that came in from PR15/16 (in 0.5.0.0) --- this change had lead to much cleaner and simpler code. Note: This change will break backwards compatibility for people who have used customRequestData before (please check sample 3 samples/global_errorhandler/errortemplate.cfm)

0.5.0.0 (Dec 31 2014): merged and edited PR/ISSUE 15/16 and fixed a CF 9 issue. Please be aware that samples have changed due to a new way of passing in custom data.

0.4.0.0alpha (Jan 10 2014): Various small fixes, merged and edited PR10

0.3.4.0alpha (May 1 2013): Various bugfixes and improvements, fix for queryString, machineName is now server's IP Address and more

0.3.0.0alpha (Apr 10 2013): Switched Stracktrace with TagContext data to make it more relevant for Dashboard display of CFML errors, implemented support for the session and param structures within request, updated sample files to reflect the changes

0.2.2.0alpha (Mar 29 2013): Various fixes, better support for cfcatch (Expression) vs error structs

0.2.1.1alpha (Mar 28 2013): Merged PR from possum888, added sample for using RG in a global errorhandler or via cferror

0.2.1.0alpha (Mar 22 2013): Added support for POST rawData, CFML Form-Scope and implemented a scope-based content filtering allowing to replace sensitive scope data before it is being sent to Raygun.io

0.1.0.0alpha (Feb 15 2013): Initial Release, tested on ACF 9.
