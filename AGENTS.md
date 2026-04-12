# AGENTS.md — Raygun4CFML

## Project Overview

Raygun4CFML (v2.1.0) is a CFML library for sending crash reports to the [Raygun API](https://raygun.com). It supports:

- **Adobe ColdFusion** 2021, 2023, 2025
- **Lucee** 5.3, 5.4, 6.0, 6.1
- **BoxLang** 1+

Package management via CommandBox (`box.json`). Code formatting via cfformat (`.cfformat.json`). Tests via TestBox.

## Repository Layout

```
src/com/raygun/
├── RaygunClient.cfc              # Main entry point
├── environment/
│   ├── RaygunConfig.cfc          # Static config (version, constants)
│   └── RaygunSettings.cfc        # User-configurable settings
├── filter/
│   └── RaygunContentFilter.cfc   # Sensitive data filtering
├── message/
│   ├── RaygunMessage.cfc         # Top-level message wrapper
│   ├── RaygunMessageDetails.cfc  # Message detail builder
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
├── environment/                  # RaygunConfigTest.cfc, RaygunSettingsTest.cfc
├── filter/                       # RaygunContentFilterTest.cfc
├── message/                      # RaygunIdentifierMessageTest.cfc, RaygunExceptionMessageTest.cfc
└── user/                         # RaygunUserCustomDataTest.cfc

samples/                          # Usage examples (app-cfc-*, try-catch, datasources-and-sql)
legacy/                           # Legacy integration notes (ColdBox 3.6.0)
server-*.json                     # CommandBox server configs for each engine
```

## Public API Surface

**User-facing components** (consumers instantiate these directly):

| Component | Package | Purpose |
|---|---|---|
| `RaygunClient` | `com.raygun` | Main client — `init(apiKey)`, `send()`, `sendAsync()` |
| `RaygunSettings` | `com.raygun.environment` | Optional behavior settings |
| `RaygunContentFilter` | `com.raygun.filter` | Filters sensitive keys from payloads |
| `RaygunUserCustomData` | `com.raygun.user` | Attach custom data/tags to reports |
| `RaygunIdentifierMessage` | `com.raygun.message` | Identify affected user |

**Internal components** (not intended for direct consumer use):

- `message/Raygun*Message.cfc` (except `RaygunIdentifierMessage`) — payload construction
- `environment/RaygunConfig.cfc` — static constants (version, defaults)
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

## Cross-Engine Compatibility

All code must work on Adobe CF 2021+, Lucee 5.3+, and BoxLang 1+.

- **CGI, FORM, URL scopes**: Always check existence before access — these may not exist in non-web contexts (threads, CLI, scheduled tasks)
- **`getHTTPRequestData()`**: Guard with try/catch — unavailable outside HTTP request contexts
- **Thread safety**: Code may run inside `cfthread`; don't assume web request context is available
- **Java integration** (MXBeans, `InetAddress`, etc.): Wrap in try/catch — Java class availability varies by engine and OS
- **Type checks**: Use case-insensitive comparisons (e.g., `compareNoCase()`) for engine-dependent type names — engines differ in casing
- **JSON serialization**: Handle ACF's `//` prefix quirk (see `buildPayload()` in `RaygunClient.cfc`)

## Testing

- Tests live in `tests/specs/com/raygun/`, mirroring `src/com/raygun/` structure
- Test files are named `*Test.cfc` and extend `testbox.system.BaseSpec`
- TestBox is a dev dependency (`"testbox": "6"` in `box.json`)
- Test any behavior change; verify against multiple engines when touching engine-dependent code

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
| `server-lucee-5-4.json` | Lucee 5.4 | 9191 |
| `server-adobe-2021.json` | Adobe CF 2021 | 9192 |
| `server-adobe-2023.json` | Adobe CF 2023 | 9193 |
| `server-lucee-6-0.json` | Lucee 6.0 | 9194 |
| `server-lucee-6-1.json` | Lucee 6.1 | 9195 |
| `server-lucee-5-3.json` | Lucee 5.3 | 9196 |
| `server-adobe-2025.json` | Adobe CF 2025 | 9198 |
| `server-boxlang-1.json` | BoxLang 1 | 9197 |

## Key Design Decisions

- **API endpoint**: All payloads POST to `https://api.raygun.com/entries` with `X-ApiKey` header
- **Version tracking**: Version is defined in both `RaygunConfig.cfc` (`RAYGUN_CLIENT_VERSION`) and `box.json` (`version`) — **keep these in sync**
- **Content filtering**: `RaygunContentFilter.apply()` runs against the fully built `RaygunMessage` struct *before* JSON serialization — this is the last chance to strip sensitive data
- **Raw data limit**: Payloads are capped at 4096 chars by default (`RaygunConfig.RAW_DATA_MAX_LENGTH_DEFAULT`)
- **Async sending**: Uses `cfthread` for non-blocking sends; errors are logged to `Raygun4CFML` log file
