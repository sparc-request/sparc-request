## Contributing to Sparc Request ##

### Pull Request Guidelines ###

Before any third-party contribution can be consider ready for submission as a
pull request, the contributor must:

* Include unit tests that provide full code coverage for all new code within
any pull request (please adhere to the specifications laid out in the
[RSpec Style Guide](https://github.com/sparc-request/sparc-request/wiki/SPARC-Request-Spec-Guide) when writing unit tests)

* Run the entire test suite and verify that all tests pass in order to avoid
breaking any existing functionality

* Adhere to the [Sparc Style Guide](https://github.com/HSSC/ruby-style-guide)

* _**NOT**_ use any languages other than Ruby, CoffeeScript and HAML

* _**NOT**_ add any new gems or frameworks without consulting the MUSC team

* _**NOT**_ change any existing file structures within the application

### Finding and reporting bugs ###
If you believe you have found a bug in the Sparc codebase, please check the [Github
Issues](https://github.com/sparc-request/sparc-request/issues) page to ensure that
the bug has not already been reported. If you are unable to find an existing issue
that matches the bug you have found, feel free to open a new issue. Please make sure
the issue has a clear title and a description with as much relevant information as
possible, including but not limited to:

* All environment details (browser, etc.)
* Steps to reproduce
* What you believe is the expected behavior, as compared to the actual behavior you
are seeing

### Fixing bugs ###
Submit a pull request! Please make sure that bug fixes adhere to the same set of
guidelines as all other pull requests (outlined above) and that there has been an
issue created on the [Github Issues](https://github.com/sparc-request/sparc-request/issues)
page to track the bug. Include the associated issue number in the pull request.

### New Features ###
If you would like to submit a new feature, please make sure to include a clear title and 
description with as much relevant information as possible, including but not limited to:

* Explain why you would like to implement this new feature
* What the expected functionality is
* Ensure that it works with our existing code base
* A detailed explanation for any new gems introduced

Make sure all pull-requests have a green test suite on Travis.
