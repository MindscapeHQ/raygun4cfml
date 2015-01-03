raygun4cfml
===========

Raygun.io client for CFML.


## Versions

Current Version: 1.0.0.0 (Jan 3 2015)

Note: This release will break your code if you've used 0.4 and older before and have used customRequestData. Please continue reading.

### History

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

## How to contribute

The main repository of this project is https://github.com/MindscapeHQ/raygun4cfml. Please fork from there, create a local develop branch and merge changes back to your local master branch to submit a pull request. Even better, get in touch with me on Twitter (@AgentK) or here on Github before you undertake any work so that it can be coordinated with what I'm doing.

Most of the active development happens in my own fork: https://github.com/TheRealAgentK/raygun4cfml - feel free to peek around in there.

## License

Copyright 2013-2015 Kai Koenig, Ventego Creative Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.







