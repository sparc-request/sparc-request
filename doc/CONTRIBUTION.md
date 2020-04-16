[//]: # (Copyright © 2011-2018 MUSC Foundation for Research Development)
[//]: # (All rights reserved.)

[//]: # (Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:)

[//]: # ( 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.)

[//]: # ( 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following)
[//]: # ( disclaimer in the documentation and/or other materials provided with the distribution.)

[//]: # ( 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products)
[//]: # " derived from this software without specific prior written permission."

[//]: # "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

## Contributing to SPARCRequest

Please follow the [Pull Request Guidelines](https://github.com/sparc-request/sparc-request/blob/master/PULL_REQUEST_GUIDELINES.md) when submitting and reviewing a pull request.

In addition to these guidelines, please remember before any third-party contribution can be considered ready for submission as a pull request, the contributor must:

* Include unit tests that provide full code coverage for all new code within
any pull request (please adhere to the specifications laid out in the
[SPARCRequest Spec Style Guide](https://github.com/sparc-request/sparc-request/wiki/SPARC-Request-Spec-Guide) when writing unit tests)

* Adhere to the [SPARC Style Guide](https://github.com/HSSC/ruby-style-guide)

* _**NOT**_ use any languages other than Ruby, CoffeeScript and HAML

* _**NOT**_ add any new gems or frameworks without consulting the governance team

* _**NOT**_ change any existing file structures within the application

## Reporting Bugs/ Requesting Features

If you believe you have found a bug in the SPARCRequest codebase or would like to request a new feature, your course of action will differ depending on the level of involvement.

### Pivotal Tracker (for Members of SPARC OS Governance Committees)

If you have access to the project “SPARC – OS Development” on Pivotal Tracker, and you have ensured that the bug/feature has not already been reported/requested, please:

1. Login to [Pivotal Tracker](https://www.pivotaltracker.com).

2. On the left hand side, click “Add Story”.

3. The title of the story/issue should have the location of the bug/feature (SPARCRequest, SPARCDashboard, SPARCCatalog, etc.) and a succinct description. For example, “(SPARCRequest & SPARCDashboard) Protocol title not displaying”

4. Set the “Story Type” to “Bug” or “Feature”

5. Tag this story with a label containing your institution’s name

6. Description:  should go into as much relevant information as possible.  See “Bug Description” and “Feature Description” below.

### Github Issue/ Google Group (for Others)
**Reporting Bugs:**

If you do not have access to the aforementioned project, visit our [Github Issues](https://github.com/sparc-request/sparc-request/issues) or [Google Group](https://groups.google.com/forum/?hl=en#!forum/sparcrequest) and submit the bug with the following format:  Title, Type, Description. *Note that any bug submitted in the Google Group will be converted into a Github Issue.

**Title:**  The title of the story/issue should have the location of the bug (SPARCRequest, SPARCDashboard, SPARCCatalog, etc.) and a succinct description.  For example:  “(SPARCRequest & SPARCDashboard) Protocol Title not Displaying Bug”.

**Type:**  Bug

**Bug Description:**  The description should go into as much relevant information as possible, including but not limited to:

* All environment details (browser, etc.)

* Steps to reproduce

* What you believe is the expected behavior, as compared to the actual behavior you are seeing

* Provide screenshots

**Requesting a Feature:**

Visit our [Google Group](https://groups.google.com/forum/?hl=en#!forum/sparcrequest) and submit the feature with the following format:  Title, Type, Description.

**Title:**  The title should have the location of the requested feature (SPARCRequest, SPARCDashboard, SPARCCatalog, etc.) and a succinct description.  For example:  “(SPARCRequest & SPARCDashboard) Add New Column to Service Calendar”.

**Type:**  Feature

**Feature Description:**  The description should go into as much relevant information as possible, including but not limited to:

* Explain why you would like to implement this new feature

* What the expected functionality is

* Provide screenshots/mock-ups

* A detailed explanation for any new gems introduced

*NOTE:  All feature requests will be reviewed by our OS Governance Committee, we will follow-up with you about the implementation.*

## Fixing bugs / Submit New Features:
Submit a pull request! Please make sure you are following the [Pull Request Guidelines](https://github.com/sparc-request/sparc-request/blob/master/PULL_REQUEST_GUIDELINES.md).

Remember to check that your Pull Request has:

* Been reviewed by at least 2 developers from the OS Governance Committee

* The Pivotal Tracker story ID (and Git Issue #, if exists)

* No merge conflicts

* Passed Travis

**Your pull request will not be merged until the above has been done.**

Last updated:  August 3, 2017
