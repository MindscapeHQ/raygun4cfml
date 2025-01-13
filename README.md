Raygun4CFML
===========

Raygun4CFML is a client library for integrating Raygun's Crash Reporting service with your CFML applications. It enables you to send error reports and crash data to Raygun for tracking and analysis.

Supported Platforms:

- Adobe ColdFusion 2021+
- Lucee 5.3+
- Boxlang 1+

Current Version: 2.0.1

## Active development

2.0.0 was a complete rewrite of the project and is ready-to-use for the 3 major CFML engines and their crash reports. 

Please be aware that no testing and work has *yet* gone into framework-specific crash reports, e.g. a deeper integration with Coldbox HVMC, Fusebox, CF on Wheels etc. This will be added over time in future releases.

## Dependencies

- Testbox (used as a development dependency for local and CI testing)

## Installation and Setup

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

## Library Usage

### Initializing RaygunClient

The `RaygunClient` is the primary component for sending error reports. You can initialize it in several ways depending on your setup:

- **Webroot Setup:**

  Place the contents of `/src` in your webroot and initialize the `RaygunClient` as follows:
  ```cfml
  raygun = createObject("component", "com.raygun.RaygunClient").init(
      apiKey = "YOURAPIKEYHERE"
  );
  ```

- **Custom Mapping:**

  Place the contents of `/src` in a directory of your choice and create a mapping to `/com` in your server administrator or through code. Them, initialise as suitable for the mapping.


### Using the Library

- **Error Reporting:**

  Once initialized, use the `RaygunClient` to send error reports with the `.send()` function. Refer to the `/samples` directory for examples.

- **Testing:**

  The `/tests` directory contains structures for Testbox unit and integration tests. Use these to validate your integration.

## Version History

For detailed version history, refer to the `CHANGELOG.md` file.

## Contribution Guidelines

Raygun4CFML is not an official Raygun library and is not maintained by Raygun staff. 

Contributions are welcome. 

Please fork the main repository at https://github.com/MindscapeHQ/raygun4cfml, create a feature branch, and submit a pull request. Coordination via X (@AgentK) or GitHub (https://github.com/TheRealAgentK/) is encouraged before starting any work.

For more active development, visit my development fork at https://github.com/TheRealAgentK/raygun4cfml.
