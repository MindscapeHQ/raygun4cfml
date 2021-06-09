History
=======

1.2.0 (Jun 8 2021)

- Support for version (#34)

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
