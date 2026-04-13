# AGENTS.md — Raygun4CFML

## Project Overview

Raygun4CFML (v3.0.0) is a CFML library for sending crash reports to the [Raygun API](https://raygun.com). It supports:

- **Adobe ColdFusion** 2021, 2023, 2025
- **Lucee** 5.3, 5.4, 6.0, 6.1, 6.2, 7.0, 7.1
- **BoxLang** 1+

Package management via CommandBox (`box.json`). Code formatting via cfformat (`.cfformat.json`). Tests via TestBox (160 specs across 11 engines).

## Repository Layout

```
src/com/raygun/
├── RaygunClient.cfc              # Main entry point
├── environment/
│   ├── RaygunConfig.cfc          # Static config (version, constants)
│   └── RaygunSettings.cfc        # User-configurable settings
├── filter/
│   └── RaygunContentFilter.cfc   # Sensitive data filtering (exact + wildcard)
├── message/
│   ├── RaygunMessage.cfc         # Top-level message wrapper
│   ├── RaygunMessageDetails.cfc  # Message detail builder
│   ├── RaygunBreadcrumbMessage.cfc # Breadcrumb entries
│   ├── RaygunClientMessage.cfc   # Client metadata
│   ├── RaygunEnvironmentMessage.cfc
│   ├── RaygunExceptionMessage.cfc
│   ├── RaygunIdentifierMessage.cfc  # User identification (public API)
│   ├── RaygunRequestMessage.cfc
│   └── RaygunResponseMessage.cfc
├── tools/
│   ├── ProductCheck.cfc          # Engine detection (static)
│   └── RaygunInternalTools.cfc   # Internal utilities
└── user/
    └── RaygunUserCustomData.cfc  # Custom diagnostic data (public API)

tests/specs/com/raygun/           # Mirrors src structure
├── RaygunClientPayloadTest.cfc
├── RaygunClientBreadcrumbTest.cfc
├── RaygunClientOnBeforeSendTest.cfc
├── RaygunClientIgnoreExceptionsTest.cfc
├── environment/                  # RaygunConfigTest.cfc, RaygunSettingsTest.cfc
├── filter/                       # RaygunContentFilterTest.cfc, RaygunContentFilterWildcardTest.cfc
├── message/                      # All message component tests
└── user/                         # RaygunUserCustomDataTest.cfc

samples/                          # Usage examples (app-cfc-*, try-catch, datasources-and-sql)
legacy/                           # Legacy integration notes (ColdBox 3.6.0)
server-*.json                     # CommandBox server configs for each engine
```

## Public API Surface

**User-facing components** (consumers instantiate these directly):

| Component | Package | Purpose |
|---|---|---|
| `RaygunClient` | `com.raygun` | Main client — `init(apiKey)`, `send()`, `sendAsync()`, `recordBreadcrumb()`, `clearBreadcrumbs()` |
| `RaygunSettings` | `com.raygun.environment` | Optional behavior settings (rawDataMaxLength, statusCode, apiEndpoint, httpTimeout, maxRetries, retryDelay) |
| `RaygunContentFilter` | `com.raygun.filter` | Filters sensitive keys from payloads (exact match + wildcard globs) |
| `RaygunUserCustomData` | `com.raygun.user` | Attach custom data/tags to reports |
| `RaygunIdentifierMessage` | `com.raygun.message` | Identify affected user |

**Internal components** (not intended for direct consumer use):

- `message/Raygun*Message.cfc` (except `RaygunIdentifierMessage`) — payload construction
- `message/RaygunBreadcrumbMessage.cfc` — individual breadcrumb entries (created by `recordBreadcrumb()`)
- `environment/RaygunConfig.cfc` — static constants (version, defaults, limits)
- `tools/ProductCheck.cfc` — engine detection
- `tools/RaygunInternalTools.cfc` — internal utilities

## Coding Conventions

- **cfscript-only** — no tag-based CFML in `src/`
- **Follow `.cfformat.json`** — run `box run-script format` before committing
- **Double quotes** for strings, **4-space indentation**, no tabs
- **Package naming**: `com.raygun.*`
- **Builder-style APIs**: `init()` returns `this`, `build()` constructs payloads, accessor-based setters/getters via `accessors="true"`
- **Static component patterns**: use `static {}` blocks for constants and `public static function` for config/tool detection (see `RaygunConfig.cfc`, `ProductCheck.cfc`)
- **No new dependencies** unless absolutely necessary — the library has zero runtime dependencies
- **Use `isCustomFunction()` not `isClosure()`** — `isClosure()` is not available on all engines
- **Use `isNull()` guards** before `isInstanceOf()` — null values passed to `isInstanceOf()` throw NPE on strict engines

## Cross-Engine Compatibility

All code must work on Adobe CF 2021+, Lucee 5.3+, and BoxLang 1+.

- **CGI, FORM, URL scopes**: Always check existence before access — these may not exist in non-web contexts (threads, CLI, scheduled tasks)
- **`getHTTPRequestData()`**: Guard with try/catch — unavailable outside HTTP request contexts
- **Thread safety**: Code may run inside `cfthread`; don't assume web request context is available
- **Java integration** (MXBeans, `InetAddress`, etc.): Wrap in try/catch — Java class availability varies by engine and OS
- **Type checks**: Use case-insensitive comparisons (e.g., `compareNoCase()`) for engine-dependent type names — engines differ in casing
- **JSON serialization**: Handle ACF's `//` prefix quirk (see `buildPayload()` in `RaygunClient.cfc`)
- **Struct null values**: ACF treats `javacast("null","")` as key removal; avoid asserting key existence for potentially-null values in tests
- **Thread attribute names**: ACF reserves `timeout` and `duration` as `cfthread` attributes — use alternative names (e.g. `httpTimeoutSecs`)
- **Regex**: Avoid complex character class escaping in `reReplace()` — different engines parse differently. Use `find()` char-by-char for portability

## Testing

- Tests live in `tests/specs/com/raygun/`, mirroring `src/com/raygun/` structure
- Test files are named `*Test.cfc` and extend `testbox.system.BaseSpec`
- TestBox is a dev dependency (`"testbox": "6"` in `box.json`)
- Test any behavior change; verify against multiple engines when touching engine-dependent code
- **160 specs** across all components — run all 11 engines before pushing

### Running tests locally

**Automated (preferred)** — uses `run-tests.sh` which starts a server, runs tests, and stops the server (cleanup on interrupt via trap):

```bash
./run-tests.sh server-lucee-6-1.json    # single engine
./run-tests.sh                           # all engines sequentially
box run-script test                      # shortcut: Lucee 6.1
box run-script test:all                  # shortcut: all engines
```

**Manual** — if you need to keep a server running for debugging:

```bash
box server start serverConfigFile=server-lucee-6-1.json
# Browse to http://localhost:9195/tests/runner.cfm
# When done:
box server stop serverConfigFile=server-lucee-6-1.json
```

> **Important:** Always stop servers when done. If a server is left running, its port will conflict with future test runs. Use `box server list` to check for running servers.

### Testing samples against Raygun

Samples load the API key automatically — no hardcoded keys in source files.

**Resolution order:** `samples/.env.json` → `RAYGUN_API_KEY` env var → placeholder string.

To set up:

```bash
cp samples/.env.json.sample samples/.env.json
# Edit samples/.env.json and paste your Raygun API key
```

`samples/.env.json` is gitignored — **never commit API keys to the repo**.

To test samples manually:

```bash
box server start serverConfigFile=server-lucee-6-1.json
# Hit sample pages, e.g.:
curl http://127.0.0.1:9195/samples/try-catch/catch_expression.cfm
curl http://127.0.0.1:9195/samples/app-cfc-no-filter/catch_throw.cfm
# Verify errors appear in the Raygun dashboard
box server stop serverConfigFile=server-lucee-6-1.json
```

## Commit Messages

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/). This is enforced by CI on PRs and direct pushes to `develop`.

**Format:** `type(scope): description`

**Valid types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Scope is optional.** Examples:

- `feat: add breadcrumb support`
- `fix(filter): handle missing rawData gracefully`
- `docs: update README with new settings options`
- `test: add RaygunResponseMessage specs`

## Change Checklist

For any public API change:

1. ✅ Add/update tests in `tests/specs/`
2. ✅ Update `README.md`
3. ✅ Update or add sample code in `samples/`
4. ✅ Add entry to `CHANGELOG.md`
5. ✅ Run `box run-script format` and `box run-script format:check`

## Code Formatting

```bash
box run-script format        # Auto-format all source, test, and sample files
box run-script format:check  # Check formatting without modifying files
```

Formatting covers `src/**/*.cfc`, `tests/**/*.cfc`, `tests/**/*.cfm`, `samples/**/*.cfc`, `samples/**/*.cfm`.

## Server Configs

| File | Engine | Port |
|---|---|---|
| `server-lucee-5-3.json` | Lucee 5.3 | 9196 |
| `server-lucee-5-4.json` | Lucee 5.4 | 9191 |
| `server-lucee-6-0.json` | Lucee 6.0 | 9194 |
| `server-lucee-6-1.json` | Lucee 6.1 | 9195 |
| `server-lucee-6-2.json` | Lucee 6.2 | 9199 |
| `server-lucee-7-0.json` | Lucee 7.0 | 9200 |
| `server-lucee-7-1.json` | Lucee 7.1 | 9201 |
| `server-adobe-2021.json` | Adobe CF 2021 | 9192 |
| `server-adobe-2023.json` | Adobe CF 2023 | 9193 |
| `server-adobe-2025.json` | Adobe CF 2025 | 9198 |
| `server-boxlang-1.json` | BoxLang 1 | 9197 |

## Key Design Decisions

- **API endpoint**: All payloads POST to `https://api.raygun.com/entries` with `X-ApiKey` header (configurable via `RaygunSettings.apiEndpoint`)
- **Version tracking**: Version is defined in both `RaygunConfig.cfc` (`RAYGUN_CLIENT_VERSION`) and `box.json` (`version`) — **keep these in sync**
- **Content filtering**: `RaygunContentFilter.apply()` runs against the fully built `RaygunMessage` struct *before* JSON serialization — this is the last chance to strip sensitive data. Supports both exact key matches and `*` glob wildcards.
- **Raw data limit**: Payloads are capped at 4096 chars by default (`RaygunConfig.RAW_DATA_MAX_LENGTH_DEFAULT`)
- **Payload size limit**: Total JSON payload is capped at 128KB (`RaygunConfig.MAX_PAYLOAD_SIZE`). Oversized payloads are progressively reduced by stripping expendable fields.
- **Form field truncation**: Form field values are truncated to 256 chars (`RaygunConfig.FORM_FIELD_MAX_LENGTH`)
- **Async sending**: Uses `cfthread` for non-blocking sends; errors are logged to `Raygun4CFML` log file
- **Retry**: Failed HTTP requests are retried up to `maxRetries` times (default: 2) with `retryDelay` seconds between attempts (default: 1)
- **Breadcrumbs**: Stored on the `RaygunClient` instance as an array of `RaygunBreadcrumbMessage` objects, built and included in `details.breadcrumbs[]` at send time
- **onBeforeSend**: Closure receives deserialized payload struct; return `false` to cancel, return modified struct to mutate, throw to proceed unchanged
- **Ignore exceptions**: Array of exception type strings checked case-insensitively against `issueData.type` before payload construction
