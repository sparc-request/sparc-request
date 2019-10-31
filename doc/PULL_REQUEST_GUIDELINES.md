## Everything Concerning Pull Requests ##

### When submitting a PR: ###

* Cleanup your commit history (if needed) to make it easier for reviewers to follow.

* The title should contain your initials followed by the name of the Pivotal Story.(“AC- (SPARCRequest) Taste The Rainbow” )

* The description should contain the Pivotal Story ID (for ease of copy paste for your reviewers).  The Pivotal Story ID should also appear after each commit message in brackets.

* Add appropriate labels.  It should always have a version label, which can be found on the Pivotal Story in the “LABELS” section.  Also include a label for your institution. (MUSC has a label entitled “musc_contribution”)

### When reviewing a PR: ###

* Find the Pivotal ID and get acquainted with the story requirements.

* Ask good questions; don't make demands. ("What do you think about naming this :user_id?")

* Ask for clarification. ("I didn't understand. Can you clarify?")

* Avoid using terms that could be seen as referring to personal traits. ("dumb", "stupid"). Assume everyone is intelligent and well-meaning.

* Be explicit. Remember people don't always understand your intentions online.

* Be humble. ("I'm not sure - let's look it up.")

* Don't use hyperbole. ("always", "never", "endlessly", "nothing")

* Don't use sarcasm.

### When requesting changes to a PR: ###

* Be as objective as possible.  Ignore your own personal design preferences.  There is more than one way to solve a problem.

* Only request changes when you see a bug or something functionally wrong, otherwise, approach the person and have a face-to-face conversation or contact them on slack.

* When approaching someone offline, site specific, objective reasons why one implementation is better than another and provide sources.

* Be respectful of each other.  This goes for commenting and responding to the comment.  Please keep in mind that it’s easy to misinterpret things that are written.  If a review seems aggressive or angry or otherwise personal, consider if it is intended to be read that way and ask the person for clarification of intent, in person if possible.

* When the requested changes have been agreed upon, the owner(s) of the pull request should be responsible for making requested changes. If they need help, they should ask the requester to collaborate. This includes functionality changes, bugs, refactors, and tasks like adding copyright statements and adding text to YML.

* If you find yourself commenting too much, _**STOP**_ and _**START**_ a conversation.

### How to approve/request changes to a PR: ###

After reviewing the PR on the “Files Changed” tab in github, in the upper right hand corner there is a “Review changes” button where you can either “Comment”, “Approve”,  or “Request Changes”.

### After submitting a PR: ###

Make sure your PR:

* Adheres to the above guidelines (title, labels, pivotal story id, etc)

* Passes on Travis

* Has been reviewed (Request Reviewers if need be)

* Has no merge conflicts


Shoutout to [Thoughtbot](https://github.com/thoughtbot/guides/tree/master/code-review) for their excellent code review doc.

Last updated:  July 6, 2017
