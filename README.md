raygun4cfml
===========

Raygun.io client for CFML.


## Versions

Current Version: 0.3.0.0alpha (Apr 10 2013)

### History


0.3.0.0alpha (Apr 10 2013): Switched Stracktrace with TagContext data to make it more relevant for Dashboard display of CFML errors, implemented support for the session and param structures within request, updated sample files to reflect the changes

0.2.2.0alpha (Mar 29 2013): Various fixes, better support for cfcatch (Expression) vs error structs

0.2.1.1alpha (Mar 28 2013): Merged PR from possum888, added sample for using RG in a global errorhandler or via cferror

0.2.1.0alpha (Mar 22 2013): Added support for POST rawData, CFML Form-Scope and implemented a scope-based content filtering allowing to replace sensitive scope data before it is being sent to Raygun.io

0.1.0.0alpha (Feb 15 2013): Initial Release, tested on ACF 9.

## How to contribute

The main repository of this project is https://github.com/MindscapeHQ/raygun4cfml. Please fork from there, create a local develop branch and merge changes back to your local master branch to submit a pull request. Even better, get in touch with me on Twitter (@AgentK) or here on Github before you undertake any work so that it can be coordinated with what I'm doing.

Most of the active development happens in my own fork: https://github.com/TheRealAgentK/raygun4cfml - feel free to peek around in there.

## License

Copyright 2013 Kai Koenig, Ventego Creative Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.







