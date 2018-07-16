## SPARCRequest Customization Options
### Contents
	
	1. Database Settings
		1.1 Adapters
		1.2 Environments
	2. Settings & Configuration
		2.1 Generic Settings
		2.2 Configuring Omniauth
		2.3 Configuring LDAP
		2.4 Configuring Epic
		2.5 Configuring RMID
		2.6 SPARCFunding
		2.7 SPARCRequest API
		2.8 Right Navigation
		2.9 Google Calendar
		2.10 News Feed
		2.11 System Satisfaction Survey
		2.12 navigation.yml
    3. Permissible Values & Constants
        3.1 Permissible Values
        3.2 constants.yml
	4. HTML Content
		4.1 Header Contents
		4.2 Page Contents and Attribute Labels
	5. Data Flags
		5.1 Organization Tags
		5.2 Catalog Overlords

### 1. Database Settings
#### 1.1 Adapters
SPARCRequest has been designed to use the mysql2 adapter, however fairly extensive testing has also been done with the sqlite3 adapter.  No postgresql adapters have been tested with the system, however they may well work.  If you desire to use any adapter other than mysql2 *heavy* testing is advised, starting with the test suite to attempt to probe for issues.
#### 1.2 Environments
SPARCRequest Rails environment configurations are mostly standard.  However the following method:

	config.action_mailer.default_url_options
will need to be set in each environment according to the sending url. Also in the development environment the letter_opener gem is utilized and thus the option:

	config.action_mailer.delivery_method = :letter_opener
should be set.

In the production environment ExceptionNotifier is setup, and its options will need to be set to the individuals that you would like to send and receive notifications when exceptions occur in production, i.e.:

	config.middleware.use ExceptionNotifier,
    	sender_address: 'no-reply@example.com',
    	exception_recipients: ['user@example.com']


### 2. Settings & Configuration
SPARCRequest utilizes a number of settings to allow you to customize content and enable or disable functionality based on your institution's needs. These settings can be found in the `settings` database table after running `rake db:migrate`.

You may opt to manually import new settings or update your existing settings by running the following command:

	rake data:import_settings

or you may entirely refresh your settings by running the following command:

	rake data:regenerate_settings

**Note** If you are upgrading from an older version of SPARCRequest, your application may still be utilizing `config/application.yml`, `config/epic.yml`, and `config/ldap.yml` for settings. Your settings will automatically be imported from these files when running the settings import task. Once your settings have been imported, these files are not longer needed and may be deleted.

#### 2.1 Generic Settings
SPARCRequest has many settings that are used internally to customize content and configurations. These settings are generated from `config/settings/application.json`.

- **about_sparc_url**:

#### 2.2 Configuring Omniauth
Your institution may opt to use [Omniauth](https://github.com/omniauth/omniauth) authentication plugins such as [CAS](https://apereo.github.io/cas/5.3.x/index.html) and [Shibboleth](https://www.shibboleth.net/) for user authentication in SPARCRequest. Only CAS and Shibboleth are supported at this time, but support for other Omniauth plugins may be implemented. These settings are generated from `config/settings/oauth.json`.

- **use_cas**:
- **use_cas_only**:
- **use_shibboleth**:
- **use_shibboleth_only**:

#### 2.3 Configuring LDAP
Your institution may opt to use [LDAP](https://ldap.com/) for managing identities in SPARCRequest. These settings are generated from `config/settings/ldap.json`.

##### LDAP Configuration
- **use_ldap**:
- **lazy_load_ldap**:
- **suppress_ldap_for_user_search**:

##### LDAP Fields
- **ldap_host**:
- **ldap_port**:
- **ldap_base**:
- **ldap_encryption**:
- **ldap_domain**:
- **ldap_uid**:
- **ldap_last_name**:
- **ldap_first_name**:
- **ldap_email**:
- **ldap_auth_username**:
- **ldap_auth_password**:
- **ldap_filter**:


#### 2.4 Configuring Epic
Your institution may opt to use [Epic](https://www.epic.com/) to store health records from SPARCRequest. These settings are generated from `config/settings/epic.json`.

##### EPIC Configuration
- **use_epic**:
- **approve_epic_rights_mail_to**:
- **queue_epic**:
- **epic_queue_access**:
- **epic_queue_report_to**:
- **queue_epic_load_error_to**:

##### EPIC Fields
- **epic_study_root**:
- **epic_endpoint**:
- **epic_namespace**:
- **epic_wsdl**:
- **epic_test_mode**:

#### 2.5 Configuring RMID
Your institution may opt to use Research Master ID (RMID) to connect records between SPARCRequest and other systems, such as eIRB and Coeus. These settings are generated from `config/settings/rmid.json`.

- **research_master_enabled**:
- **research_master_link**:
- **research_master_api**:
- **rmid_api_token**:

#### 2.6 SPARCFunding
Your institution may opt to use the SPARCFunding module to keep track of funding opportunities. These settings are generated from `config/settings/funding.json`.

- **use_funding_module**:
- **funding_admins**:
- **funding_org_ids**:

#### 2.7 SPARCRequest API
Your institution may opt to use the SPARCRequest API to communicate with external applications, such as SPARCFulfillment. These settings are generated from `config/settings/api.json`.

- **current_api_version**:
- **remote_service_notifier_protocol**:
- **remote_service_notifier_username**:
- **remote_service_notifier_password**:
- **remote_service_notifier_host**:
- **remote_service_notifier_path**:

#### 2.8 Right Navigation

SPARCRequest provides various configurable help links below the service cart (AKA Right Navigation). These include a Feedback button, Frequently Asked Questions button, and Short Interaction button. These settings are generated from `config/settings/right_navigation.json`.

##### Feedback
- **use_feedback_link**:
- **feedback_link**:
- **feedback_mail_to**:
- **use_redcap_api**:
- **redcap_api_url**:
- **redcap_api_token**:

##### Help/FAQs
- **use_faq_link**:
- **faq_url**:

##### Short Interaction
- **use_short_interaction**:

#### 2.9 Google Calendar
Your institution may opt to integrate Google Calendar to display events on the SPARCRequest homepage. These settings are generated from `config/settings/calendar.json`.

- **use_google_calendar**:
- **calendar_url**:

#### 2.10 News Feed
Your institution may opt to integrate an external blog for the news feed on the SPARCRequest homepage. These settings are generated from `config/settings/news_feed.json`.

- **use_news_feed**:
- **news_feed_url**:
- **news_feed_post_selector**:
- **news_feed_title_selector**:
- **news_feed_link_selector**:
- **news_feed_date_selector**:

#### 2.11 System Satisfaction Survey
Your institution may opt to provide users with a system satisfaction survey prior to submitting a service request. These settings are generated from `config/settings/system_satisfaction.json`.

- **system_satisfaction_survey**:
- **system_satisfaction_survey_cc**:

#### 2.12 navigation.yml
`config/navigation.yml` lays out the navigation instructions for the service request portion of SPARCRequest. Aside from changing the 'step_text' or the 'css_class' of steps, the contents of this file should not be edited unless you have made significant changes to the application.  Each 'step' has certain parameters:

- **step_text**: This is the name of the step which shows up on the page
- **css_class**: This is the color value for the step, the current color values are matched with the arrows in the graphic at the top of the page.
- **back**: What page the application should navigate to if the user presses the 'Go Back' button at the bottom of the page.
- **forward**: What page the application should navigate to if the user presses the 'Save and Continue' button at the bottom of the page.- 
- **validation_groups**: This is where the service request validations that must be passed for the step to continue are specified.  Due to the 'wizard' mechanism by which Service Requests are assembled, the validations for required fields and such must be split up so that only relevant validations are run at any given step. The first option present under the 'validation_groups' option is the destination for which you want a given group of validations to fire.  Thus if the setup is as follows:


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

### 3. Permissible Values & Constants

#### 3.1 Permissible Values


#### 3.2 constants.yml
In config/constants.yml a list of constants across the application can be found.  The following categories are customizable:

##### Protocol Attributes
- **impact_areas**: This is a list of available impact areas which users will see as checkboxes on the Project/Study forms. (Examples: Pediatrics, Diabetes, Cancer)
- **affiliations**: This is a list of available affiliations which users will see as checkboxes on the Project/Study forms. (Examples: Cancer Center, Oral Health COBRE)
- **study_types**: This is a list of available study types which users will see as checkboxes on the Project/Study forms. (Examples: Clinical Trials, Basic Science)
- **submission_types**: This is a list of submission types that the users can select from in a drop down in the Project/Study forms. (Examples: Exempt, Expedited)
- **study_phases**: This is a list of study phases that the user can select from in a drop down in the Project/Study forms. (Examples: I, II, III, IV)

##### Associated User Attributes
- **user_roles**: This is a list of available roles which can be selected for users associated with a given Project/Study. Several of these are logic driven (PI, Co-Investigator, Other) and should not be removed from the list (PI in particular should not be changed or removed, and if it is, a lot of application wide changes will need to be made).
- **institutions**: This is a list of institutions which a given identity can be associated with.  Include whatever institutions you would like your users to be able to associate themselves with. (Examples: University of South Carolina, Clemson University)
- **colleges**: This is a list of colleges which a given identity can be associated with.  Include whatever colleges you would like your users to be able to associate themselves with. (Examples: College of Medicine, College of Nursing)
- **departments**: This is a list of departments which a given identity can be associated with.  Include whatever departments you would like your users to be able to associate themselves with. (Examples: Student Programs, Pediatrics, Radiology)
- **user_credentials**: This is a list of credentials which identities can possess.  Include whatever credentials you would like your identities to have attributed to them. (Examples: MD, PhD, MS)

##### General Attributes
- **document_types**: This is a list of document types which users can assign to document uploads. (Examples: Protocol, Consent, Budget)
- **accordion_color_options**: This is a list of colors which are matched to css classes which you have specified in the stylesheets.  The first color value specifies what you are allowed to enter in the service catalog for an organization, and the second value is the name of the css class which specifies the color. (Example: 'blue': 'blue-provider')

There are other constants in this file, however they generally should not be modified.  Explanation of each is as follows:

- **funding_statuses**: There are several important pieces of logic in the application that depend on whether a Project/Study is 'Funded' or 'Pending Funding'.  If you would like to add more options to the list, or to change the current options, you will need to modify the application logic which is defined by these options.
- **funding_sources/potential_funding_sources**: These funding sources are also tied to a good amount of application logic, for instance pricing setups and indirect cost rates, as well as general form logic (required fields changing when different funding sources are selected).  If you would like to add/edit/remove then careful attention should be paid to application logic.
- **federal_grant_codes**: This is a list of the available federal grant codes.  Unless new grant codes are established, or current ones are removed, this list should be static.
- **federal_grant_phs_sponsors/federal_grant_non_phs_sponsors**: These are lists of available federal grant phs and non-phs sponsors.  Unless codes for new sponsors are established, or current ones removed, this list should be static.
- **subspecialities**: This is a list of subspecialties with their corresponding codes.  Unless new codes are established, or current ones removed, this list should be static.
- **proxy_rights**: This is a list of the proxy rights which an identity associated with a Project/Study can be given.  Altering this list will have major application logic implications, and as such it should generally not be altered.  If your institution requires you to add or remove proxy rights from this list, a large amount of code refactoring and testing will be required.

### 4. HTML Content
#### 4.1 Header Content
The header is made up of three elements:  An organization logo, a department logo, and an institution logo.  Each is clickable and will send the user to a designated page (header_link 1, 2, and 3 described in section 2.1).  The images should be named and placed in app/assets/images and are named as follows:

	org_logo_197x57.png
	department_name_460x60.gif
	institution_logo_136x86.gif
The file formats are not important, however the sizes which are shown in the filenames (in pixels), as well as the filenames themselves, should be maintained.  If you wish to use images that do not fit those size specifications you will need to do more work in the stylesheets to insure that the header is still in alignment.

#### 4.2 Page Contents and Attribute Labels
All of the page-content and attribute label text in the application can be customized in the file config/locales/en.yml. The text is separated into sections (i.e. 'signup', 'signin', 'cart_help') that describe the area in which the following pieces of text can be found in the application.

### 5. Data Flags
#### 5.1 Organization Tags
An organization can be given tags to either aid in categorization, or to apply specific functionality.  A Catalog Manager can add whatever tags they would like for their own convenience, however there are some tags that ascribe specific functionality to any sub service requests that belong to that organization.  Tags are entered as a comma separated list such as:

	hospital, nursing, services

There are currently two tags which ascribe additional functionality:

- ctrc - Any organization that has this tag gets a set of features activated in the application which are unique to CTRC (Clinical and Translational Research Center -- aka GCRC) organizations, for instance the 'CTRC Approved' status for service requests.
- required forms - This flag is currently used to attach a particular pdf to the emails set out when a service request is submitted for services from any organization with this tag.

Any 'functional' tags that your organization will need will need to have changes made in the codebase to take effect, otherwise they will simply be 'non-functional'.

#### 5.2 Catalog Overlords
Catalog Overlord is an attribute on identities (which can be set to true or false) that determines whether a given identity, when accessing the catalog_manager, has the ability to check or uncheck the 'edit historic pricing' flag on catalog managers that have been assigned to organizations.  If this flag is checked, then that identity will then be able to modify pricing maps/pricing setups that have display/effective dates in the past.

The catalog_overlord attribute is not able to be set within the application itself.  It has to be done by a developer either through the rails console, or via direct SQL manipulation.
