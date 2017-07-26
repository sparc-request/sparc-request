##SPARC Request Customization Options
###Contents
	
	1 Database Settings
		1.1 Adapters
		1.2 Environments
	2 Configuration Settings
		2.1 application.yml
		2.2 constants.yml
		2.3 ldap.yml
		2.4 navigation.yml
		2.5 obis_setup.rb
	3 HTML Content
		3.1 Header Contents
		3.2 Page Contents and Attribute Labels
	4 Data Flags
		4.1 Organization Tags
		4.2 Catalog Overlords

###Database Settings
####1.1 Adapters
SPARC Request has been designed to use the mysql2 adapter, however fairly extensive testing has also been done with the sqlite3 adapter.  No postgresql adapters have been tested with the system, however they may well work.  If you desire to use any adapter other than mysql2 *heavy* testing is advised, starting with the test suite to attempt to probe for issues.
####1.2 Environments
SPARC Request Rails environment configurations are mostly standard.  However the following method:

	config.action_mailer.default_url_options
will need to be set in each environment according to the sending url. Also in the development environment the letter_opener gem is utilized and thus the option:

	config.action_mailer.delivery_method = :letter_opener
should be set.

In the production environment ExceptionNotifier is setup, and its options will need to be set to the individuals that you would like to send and receive notifications when exceptions occur in production, i.e.:

	config.middleware.use ExceptionNotifier,
    	sender_address: 'no-reply@example.com',
    	exception_recipients: ['user@example.com']


###Configuration Settings
####2.1 application.yml
Several important settings can be found in config/application.yml.  There is an example file found at config/application.yml.example in the repo which shows available settings with example inputs.  They are explained as follows:

- default_mail_to: This field will overwrite the mailers in the application to instead mail to this address.  To be overwritten in development/testing/staging to prevent real emails being sent out to general users.
- admin_mail_to: Same as above except for admin emails.
- feedback_mail_to: Same as above except for the recipients of feedback emails.
- new_user_cc: Same as above except for users cc'd when a new user request is submitted.
- system_satisfaction_survey_cc: Sames as above except for users cc'd when a system satisfaction survey is submitted 
- root_url: This is the root url for the application 
- dashboard_link: This is the url for the user dashboard
- header_link_1: This is the url for the first image in the header 
- header_link_2: This is the url for the second image in the header
- header_link_3: This is the url for the third image in the header 
- use_indirect_cost: This is a true/false setting which determines whether the application will display indirect costs to the users.  If true, than in addition to direct costs and direct cost subtotals, users will also see indirect costs and indirect cost subtotals, and indirect costs will also be included in the grand total.  If set to false, indirect costs will not be displayed, and they will not be included in the totals.
- use_shiboleth: This option controls whether the single user sign on option will be displayed in the application.  Currently this is only shibboleth, if you would like to use another oAuth module, this will need to be set to true.
- use_ldap: This option controls whether the associated user search will attempt to connect to an LDAP server.  If false, it will simply search the database. NOTE: Even if this is set to false at least a blank ldap.yml is required.
- wkhtmltopdf_location: Optional location for wkhtmltopdf if not using one supplied by gem eg. '/usr/local/bin/wkhtmltopdf'
- approve_epic_rights_mail_to: Email addresses of users who are e-mailed for EPIC rights approval
- use_epic: This option controls whether or not EPIC integration will be used, true/false
- queue_epic: This options controls whether EPIC pushes will be queued or not, true/false, emptying the queue is done via rake epic:batch_load, this can setup as a cronjob to run at a certain interval
- queue_epic_load_error_to: This is a list of users who will receive messages about the status of EPIC loads via queue
- epic_users_team: This is a list of email addresses to send notifications to after a protocol has been added to the EPIC queue 
- use_google_calendar: This options controls whether or not to show a google calendar on the home page, true/false
- use_news_feed: This options controls whether or not to pull a news feed, true/false, should be set to false for all except MUSC
- google_username: The username used to login to retrieve calendar data 
- google_password: The password used to login to retrieve calendar data
- send_authorized_user_emails: This options controls whether authorized user changes should send a notification, true/false


####2.2 constants.yml
In config/constants.yml a list of constants across the application can be found.  The following categories are customizable:

- Protocol Attributes
	- impact_areas: This is a list of available impact areas which users will see as checkboxes on the Project/Study forms. (Examples: Pediatrics, Diabetes, Cancer)
	- affiliations: This is a list of available affiliations which users will see as checkboxes on the Project/Study forms. (Examples: Cancer Center, Oral Health COBRE)
	- study_types: This is a list of available study types which users will see as checkboxes on the Project/Study forms. (Examples: Clinical Trials, Basic Science)
	- submission_types: This is a list of submission types that the users can select from in a drop down in the Project/Study forms. (Examples: Exempt, Expedited)
	- study_phases: This is a list of study phases that the user can select from in a drop down in the Project/Study forms. (Examples: I, II, III, IV)

- Associated User Attributes
	- user_roles: This is a list of available roles which can be selected for users associated with a given Project/Study. Several of these are logic driven (PI, Co-Investigator, Other) and should not be removed from the list (PI in particular should not be changed or removed, and if it is, a lot of application wide changes will need to be made).
	- institutions: This is a list of institutions which a given identity can be associated with.  Include whatever institutions you would like your users to be able to associate themselves with. (Examples: University of South Carolina, Clemson University)
	- colleges: This is a list of colleges which a given identity can be associated with.  Include whatever colleges you would like your users to be able to associate themselves with. (Examples: College of Medicine, College of Nursing)
	- departments: This is a list of departments which a given identity can be associated with.  Include whatever departments you would like your users to be able to associate themselves with. (Examples: Student Programs, Pediatrics, Radiology)
	- user_credentials: This is a list of credentials which identities can possess.  Include whatever credentials you would like your identities to have attributed to them. (Examples: MD, PhD, MS)

- General Attributes
	- document_types: This is a list of document types which users can assign to document uploads. (Examples: Protocol, Consent, Budget)
	- accordion_color_options: This is a list of colors which are matched to css classes which you have specified in the stylesheets.  The first color value specifies what you are allowed to enter in the service catalog for an organization, and the second value is the name of the css class which specifies the color. (Example: 'blue': 'blue-provider')

There are other constants in this file, however they generally should not be modified.  Explanation of each is as follows:

- funding_statuses: There are several important pieces of logic in the application that depend on whether a Project/Study is 'Funded' or 'Pending Funding'.  If you would like to add more options to the list, or to change the current options, you will need to modify the application logic which is defined by these options.
- funding_sources/potential_funding_sources: These funding sources are also tied to a good amount of application logic, for instance pricing setups and indirect cost rates, as well as general form logic (required fields changing when different funding sources are selected).  If you would like to add/edit/remove then careful attention should be paid to application logic.
- federal_grant_codes: This is a list of the available federal grant codes.  Unless new grant codes are established, or current ones are removed, this list should be static.
- federal_grant_phs_sponsors/federal_grant_non_phs_sponsors: These are lists of available federal grant phs and non-phs sponsors.  Unless codes for new sponsors are established, or current ones removed, this list should be static.
- subspecialities: This is a list of subspecialties with their corresponding codes.  Unless new codes are established, or current ones removed, this list should be static.
- proxy_rights: This is a list of the proxy rights which an identity associated with a Project/Study can be given.  Altering this list will have major application logic implications, and as such it should generally not be altered.  If your institution requires you to add or remove proxy rights from this list, a large amount of code refactoring and testing will be required.

####2.3 ldap.yml
Settings relevant to your institution's LDAP can be found in config/ldap.yml. There is an example file found at config/ldap.yml.example in the repo which shows available settings with example inputs.  They are explained as follows:

- ldap_host: The host server for your institution's LDAP.
- ldap_port: The port at which LDAP is accessible on that server.
- ldap_base: These are the LDAP base suffixes for your institution's LDAP.
- ldap_encryption: This is the type of encryption present on your institution's LDAP.
- ldap_domain: This is the domain suffix found on the ldap_uid of your users. (Example: for anc63@musc.edu the domain is 'musc.edu')
- ldap_uid: This is the key in your institution's LDAP records that corresponds to the uid of a given user.
- ldap_last_name: This is the key in your institution's LDAP records that corresponds to the last name/surname of a given user.
- ldap_first_name: This is the key in your institution's LDAP records that corresponds to the first name/given name of a given user.
- ldap_email: this is the key in your institution's LDAP records that corresponds to the email of a given user.

####2.4 navigation.yml
This file lays out the navigation instructions for the service request portion of SPARC Request. Aside from changing the 'step_text' or the 'css_class' of steps, the contents of this file should not be edited unless you have made significant changes to the application.  Each 'step' has certain parameters:

- step_text: This is the name of the step which shows up on the page
- css_class: This is the color value for the step, the current color values are matched with the arrows in the graphic at the top of the page.
- back: What page the application should navigate to if the user presses the 'Go Back' button at the bottom of the page.
- catalog: What page the application should navigate to if the user presses the 'Back to Catalog' button under the shopping cart throughout the application.
- forward: What page the application should navigate to if the user presses the 'Save and Continue' button at the bottom of the page.- 
- validation_groups: This is where the service request validations that must be passed for the step to continue are specified.  Due to the 'wizard' mechanism by which Service Requests are assembled, the validations for required fields and such must be split up so that only relevant validations are run at any given step. The first option present under the 'validation_groups' option is the destination for which you want a given group of validations to fire.  Thus if the setup is as follows:

		service_details:
		  ...
		  validation_groups:
		    catalog:
		      - service_details_back
		    protocol:
		      - service_details_back
		     save_and_exit:
		       - service_details_back
		     service_calendar:
		       - service_details
This would mean that on the service details page, when navigating to the catalog page, protocol page, or the save_and_exit page, that the 'service_details_back' group of validations should fire.  If the user attempts to navigate to the 'service_calendar' page (which in this case would be by pressing the 'Save and Continue' button) it will fire the validations in the 'service_details' category (fields which are validated can be found in the Service Request model).

PLEASE NOTE: Even if you do not intend to use LDAP you will need an empty ldap.yml file.

####2.5 epic.yml
Settings relevant to your institution's EPIC setup. There is an example file found at config/epic.yml.example
  
- study_root: eg. '1.2.3.4'
- endpoint: eg. 'http://TODO/'
- namespace: eg. 'urn:ihe:qrph:rpe:2009'

####2.6 obis_setup.rb
This file (in config/initializers/obis_setup.rb) reads in the YAML files that have been described above and turns them into ruby constants so that they can be accessed in the application.  This file generally should not need to be changed unless you have changed the names of attributes in the YAML files or you need to add/remove constants from the application.

###HTML Content
####3.1 Header Content
The header is made up of three elements:  An organization logo, a department logo, and an institution logo.  Each is clickable and will send the user to a designated page (header_link 1, 2, and 3 described in section 2.1).  The images should be named and placed in app/assets/images and are named as follows:

	org_logo_197x57.png
	department_name_460x60.gif
	institution_logo_136x86.gif
The file formats are not important, however the sizes which are shown in the filenames (in pixels), as well as the filenames themselves, should be maintained.  If you wish to use images that do not fit those size specifications you will need to do more work in the stylesheets to insure that the header is still in alignment.

####3.2 Page Contents and Attribute Labels
All of the page-content and attribute label text in the application can be customized in the file config/locales/en.yml. The text is separated into sections (i.e. 'signup', 'signin', 'cart_help') that describe the area in which the following pieces of text can be found in the application.

###Data Flags
####4.1 Organization Tags
An organization can be given tags to either aid in categorization, or to apply specific functionality.  A Catalog Manager can add whatever tags they would like for their own convenience, however there are some tags that ascribe specific functionality to any sub service requests that belong to that organization.  Tags are entered as a comma separated list such as:

	hospital, nursing, services

There are currently two tags which ascribe additional functionality:

- ctrc - Any organization that has this tag gets a set of features activated in the application which are unique to CTRC (Clinical and Translational Research Center -- aka GCRC) organizations, for instance the 'CTRC Approved' status for service requests.
- required forms - This flag is currently used to attach a particular pdf to the emails set out when a service request is submitted for services from any organization with this tag.

Any 'functional' tags that your organization will need will need to have changes made in the codebase to take effect, otherwise they will simply be 'non-functional'.

####4.2 Catalog Overlords
Catalog Overlord is an attribute on identities (which can be set to true or false) that determines whether a given identity, when accessing the catalog_manager, has the ability to check or uncheck the 'edit historic pricing' flag on catalog managers that have been assigned to organizations.  If this flag is checked, then that identity will then be able to modify pricing maps/pricing setups that have display/effective dates in the past.

The catalog_overlord attribute is not able to be set within the application itself.  It has to be done by a developer either through the rails console, or via direct SQL manipulation.
