# Releasing Raygun4CFML

This document describes the steps to cut a release of Raygun4CFML.

## Pre-Release Checklist

Before starting the release process:

- [ ] All features and fixes for this release are merged to `develop`
- [ ] `CHANGELOG.md` is up to date with all changes
- [ ] `README.md` reflects the current API and features
- [ ] Samples in `samples/` are updated for any new features
- [ ] `box run-script format:check` passes with no issues
- [ ] All tests pass on all 20 engines: `./run-tests.sh`

## Version Locations

The version string is tracked in **two** files — always keep them in sync:

| File | Field |
|---|---|
| `src/com/raygun/environment/RaygunConfig.cfc` | `RAYGUN_CLIENT_VERSION` (in `static {}` block) |
| `box.json` | `version` and `location` |

The test in `tests/specs/com/raygun/environment/RaygunConfigTest.cfc` asserts the version — update it too.

## Release Types

### Release Candidate (`x.y.z-rc.N`)

Use when the code is feature-complete but needs real-world validation before a final release.

### Final Release (`x.y.z`)

Use when confident the release is production-ready.

## Step-by-Step Process

### 1. Update version strings

Replace the current version in all three locations:

- `src/com/raygun/environment/RaygunConfig.cfc` → `RAYGUN_CLIENT_VERSION`
- `box.json` → `version` and `location` (e.g., `MindscapeHQ/raygun4cfml#3.0.0`)
- `tests/specs/com/raygun/environment/RaygunConfigTest.cfc` → version assertion

### 2. Update CHANGELOG.md

Change the `(Unreleased)` marker to the version and date:

```
3.0.0 (April 15, 2026)
```

### 3. Run the full test matrix

```bash
./run-tests.sh
```

All 20 engines must pass. Do not proceed if any engine fails.

### 4. Commit the release

```bash
git add src/com/raygun/environment/RaygunConfig.cfc box.json CHANGELOG.md tests/specs/com/raygun/environment/RaygunConfigTest.cfc
git commit -m "chore: release x.y.z"
```

### 5. Tag the release

```bash
git tag -a x.y.z -m "Release x.y.z"
```

### 6. Push to remote

```bash
git push origin develop --tags
```

### 7. Verify CI

Wait for the GitHub Actions CI to pass on all 20 engines before proceeding.

### 8. Publish to ForgeBox

```bash
# Log in if not already authenticated
box forgebox login

# Publish
box publish
```

Verify the package at https://www.forgebox.io/view/raygun4cfml

### 9. Create a GitHub Release (optional)

Go to https://github.com/MindscapeHQ/raygun4cfml/releases and create a release from the tag. Copy the relevant section from `CHANGELOG.md` as the release notes.

## Post-Release

After a final release:

1. Bump version to the next snapshot (e.g., `3.1.0-snapshot`) in `RaygunConfig.cfc`, `box.json`, and the test
2. Add a new `(Unreleased)` section to `CHANGELOG.md`
3. Commit: `git commit -m "chore: bump version to x.y.z-snapshot"`
4. Push: `git push origin develop`

## Promoting RC to Final

To promote a release candidate to final:

1. Follow the same steps above, changing `x.y.z-rc.N` to `x.y.z`
2. Update `CHANGELOG.md` date to the final release date
3. Run the full test matrix, tag, push, and publish

## Social Media

When announcing a release:

- **Twitter/X**: Tag `@raygunio` for Raygun. Keep under 280 chars or use a thread.
- **LinkedIn**: Longer format with feature highlights, engine coverage, and install command.
- Include the GitHub URL and ForgeBox URL.
- Include the install command: `box install raygun4cfml@x.y.z`

## Troubleshooting

### ForgeBox publish fails with authentication error

```bash
box forgebox login
box forgebox whoami   # verify you're logged in
box publish
```

### CI fails after version bump

Check that the version assertion in `RaygunConfigTest.cfc` matches the new version string.

### Test failures on specific engines

Run that engine individually and inspect the output:

```bash
box server start serverConfigFile=server-adobe-2025.json
curl -s "http://localhost:9198/tests/runner.cfm?reporter=json" | python3 -m json.tool
box server stop serverConfigFile=server-adobe-2025.json
```
