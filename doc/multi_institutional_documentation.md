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
      2.6 SPARCFulfillment
      2.7 SPARCFunding
      2.8 SPARCRequest API
      2.9 Right Navigation
      2.10 Google Calendar
      2.11 News Feed
      2.12 Tableau
      2.13 System Satisfaction Survey
      2.14 navigation.yml
    3. Permissible Values & Constants
      3.1 Permissible Values
      3.2 constants.yml
    4. DotENV
    5. Localization
    6. Data Flags
      6.1 Organization Tags
      6.2 Catalog Overlords

### 1. Database Settings
#### 1.1 Adapters
SPARCRequest has been designed to use the mysql2 adapter, however fairly extensive testing has also been done with the sqlite3 adapter. No postgresql adapters have been tested with the system, however they may well work. If you desire to use any adapter other than mysql2 *heavy* testing is advised, starting with the test suite to attempt to probe for issues.

#### 1.2 Environments
SPARCRequest Rails environment configurations are mostly standard. However the following method:

    config.action_mailer.default_url_options

will need to be set in each environment according to the sending url. Also in the development environment the letter_opener gem is utilized and thus the option:

    config.action_mailer.delivery_method = :letter_opener

should be set.

In the production environment ExceptionNotifier is setup, and its options will need to be set to the individuals that you would like to send and receive notifications when exceptions occur in production, i.e.:

    config.middleware.use ExceptionNotifier,
      sender_address: 'no-reply@example.com',
      exception_recipients: ['user@example.com']

### 2. Settings & Configuration
SPARCRequest utilizes a number of settings to allow you to customize content and enable or disable functionality based on your institution's needs. These settings are stored in the `settings` database table and are populated from `config/defaults.json`.

We highly recommend saving your environment's settings to avoid losing your settings. To do this, first run the following commands:

    # application.yml will hold the majority of your stored setting values
    cp config/application.yml.example config/application.yml

    # epic.yml will hold your epic configuration values
    cp config/epic.yml.example config/epic.yml

    # ldap.yml will hold your ldap configuration values
    cp config/ldap.yml.example config/ldap.yml

These files will hold your setting values. When the application imports settings, it will prioritize the values specified in these files for your current environment. **Note:** You may add or remove environemnts from these files as needed.

To manually import new settings, run the following command:

    rake data:import_settings

To entirely refresh your settings, run the following command:

    rake data:regenerate_settings

#### 2.1 Generic Settings
SPARCRequest has many settings that are used internally to customize content and configurations.

##### Emails
- **send_emails_to_real_users**: This tells the application whether or not to send emails to users. When turned off, emails will be generated in the browser but not sent. This should be turned off in development environments.
- **send_authorized_user_emails**: This determines whether the application will send emails to all authorized users with `View` or greater rights.
- **root_url**: This is the root URL for the application for use in emails.
- **dashboard_link**: This is the URL of SPARCDashboard for use in emails.
- **admin_mail_to**: This field will overwrite the admin user mailers in the application to instead mail to this address. This is overwritten in development/testing/staging environments in order to prevent real emails from being sent out to admin users.
- **default_mail_to**: This field will overwrite the mailers in the application to instead mail to this address. This is overwritten in development/testing/staging environments in order to prevent real emails from being sent out to general users.
- **listserv_mail_to**: This is the emails of users who are emailed by the Listserv link in the footer.
- **new_user_cc**: This field will overwrite the new user mailers in the application to instead cc to this address. This is overwritten in development/testing/staging environments in order to prevent real emails from being sent out to general users.
- **no_reply_from**: This is the email that will appear as the sender of all emails sent from the application.

##### Links and URLs
- **about_sparc_url**: This is the URL linked to by the `About SPARCRequest` button on the homepage.
- **header_link_1**: This is the URL for the _**Organization Logo**_ - the left image in the SPARCRequest header.
- **header_link_2_proper**: This is the URL for the _**SPARCRequest Logo**_ in the SPARCRequest header.
- **header_link_2_dashboard**: This is the URL for the _**SPARCDashboard Logo**_ in the SPARCDashboard header.
- **header_link_2_catalog**: This is the URL for the _**SPARCCatalog Logo**_ in the SPARCCatalog header.
- **header_link_3**: This is the URL for the _**Institution Logo**_ - the right image in the SPARCRequest header.
- **navbar_links**: This defines the links that appear in the header navbar.
  - **SPARCRequest**: This is a link to the SPARCRequest homepage.
  - **SPARCDashboard**: This is a link to SPARCDashboard.
  - **SPARCFulfillment**: This is an optional link to SPARCFulfillment.
  - **SPARCCatalog**: This is a link to SPARCCatalog.
  - **SPARCReport**: This is an optional link to the SPARCReport module.
  - **SPARCForms**: This is an optional link to the SPARCForms module.
  - **SPARCFunding**: This is an optional link to the SPARCFunding module.
  - **Other Links**: New links may be added by using the following syntax: `\"key\": [\"Link Text\", \"Full URL\"]`.

##### Statuses
- **updatable_statuses**: This defines the statuses that a SubServiceRequest can be updated from. Any other statuses are considered `un-updatable`.
- **finished_statuses**: This defines the statuses in which a SubServiceRequest is considered complete. When in these statuses, SubServiceRequests can't be updated. New services from those organizations will be added to new SubServiceRequests.

##### Other Settings
- **host**: This is the host domain of your instance of SPARCRequest.
- **site_admins**: This is a list of users who will have full access to the Survey/Form builder and SPARCForms.
- **use_indirect_cost**: This determines how the application displays costs to users. If turned on, then in addition to direct costs and direct cost subtotals, users will also see indirect costs and indirect cost subtotals, and indirect costs will also be included in the grand total. If turned off, then indirect costs will not be displayed to users, nor included in the grand total.
- **use_separate_audit_database**: This determines whether the application will store audits in a separate datebase. The application expects this database to be named `audit_#{Rails.env}`.
- **wkhtmltopdf_location**: This is a customizable path pointing to the binary for the `wkhtmltopdf` gem which is used to generate PDFs of HTML content. The default value provided by the gem is `/usr/local/bin/wkhtmltopdf`.

#### 2.2 Configuring Omniauth
Your institution may opt to use [Omniauth](https://github.com/omniauth/omniauth) authentication plugins such as [CAS](https://apereo.github.io/cas/5.2.x/index.html) and [Shibboleth](https://www.shibboleth.net/) for user authentication in SPARCRequest. Only CAS and Shibboleth are supported at this time, but support for other Omniauth plugins may be implemented.

##### Omniauth Configuration
- **use_cas**: This determines whether the application will allow users to log in using CAS.
- **use_cas_only**: This determines whether the application will only allow users to log in using CAS. This has lower precedence than `use_shibboleth_only` when both are enabled.
- **use_shibboleth**: This determines whether the application will allow users to log in using Shibboleth.
- **use_shibboleth_only**: This determines whether the application will only allow users to log in using Shibboleth. This has higher precedence than `use_shibboleth_only` when both are enabled.

#### 2.3 Configuring LDAP
Your institution may opt to use [LDAP](https://ldap.com/) for managing identities in SPARCRequest. You should save your environment's LDAP settings by overriding the values in `config/ldap.yml`.

##### LDAP Configuration
- **use_ldap**: This determines whether the authorized user search will attempt to connect to an LDAP server. If turned off, it will simply search the database.
- **lazy_load_ldap**: When enabled, the database will return only LDAP Identities found in the database and will not create new entries. When disabled, if an LDAP Identity is not found in the database, a record will be created for that user and returned.
- **suppress_ldap_for_user_search**: Allow the use of LDAP but suppress its use within the authorized user search.

##### LDAP Fields
- **ldap_host**: This is the host server for your institution's LDAP.
- **ldap_port**: This is the port at which LDAP is accessible on the server.
- **ldap_base**: This is the LDAP base suffixes for your institution's LDAP.
- **ldap_encryption**: This is the type of encryption present on your institution's LDAP.
- **ldap_domain**: This is the domain suffix found on the ldap_uid of your users. (Ex: The domain of `anc63@musc.edu` is `musc.edu`)
- **ldap_uid**: This is the key in your institution's LDAP records that corresponds to the uid of a given user.
- **ldap_last_name**: This is the key in your institution's LDAP records that corresponds to the last name/surname of a given user.
- **ldap_first_name**: This is the key in your institution's LDAP records that corresponds to the first name/given name of a given user.
- **ldap_email**: This is the key in your institution's LDAP records that corresponds to the email of a given user.
- **ldap_auth_username**: This is an optional username to access your institution's LDAP.
- **ldap_auth_password**: This is an optional password to access your institution's LDAP.
- **ldap_filter**: This is an optional filter that allows you to control how LDAP searches for an identity. Filter documentation can be found [here](https://ldap.com/ldap-filters/).


#### 2.4 Configuring Epic
Your institution may opt to use [Epic](https://www.epic.com/) to store health records from SPARCRequest. You should save your environment's Epic settings by overriding the values in `config/epic.yml`.

##### Epic Configuration
- **use_epic**: This determines whether the application will use Epic integration.
- **validate_epic_users**: This determines whether or not the application will validate Authorized Users with Epic access against a list of users from Epic.
- **epic_user_endpoint**: This is the endpoint for the Epic interface to retrieve users to validate Authorized Users with Epic access.
- **epic_user_collection_name**: This is the name of the collection of users from the Epic User Endpoint.
- **approve_epic_rights_mail_to**: Email addresses of users who are e-mailed for EPIC rights approval.
- **queue_epic**: This determines whether Epic pushes will be queued. Emptying the queue is done via `rake epic:batch_load`. This can be set up as a cronjob to run at a certain interval.
- **epic_queue_access**: This is a list of users who will have full access to the Epic queue from SPARCDashboard.
- **epic_queue_report_to**: This is the email(s) that will be sent Epic queue reports when they are generated.
- **queue_epic_load_error_to**: This is the email(s) that will be notified when errors occur in the Epic queue.

##### Epic Fields
- **epic_study_root**: This is the root URL of your institution's Epic API.
- **epic_endpoint**: This is the endpoint address for your institution's Epic SOAP message receiver.
- **epic_namespace**: This is the namespace of your institution's Epic API.
- **epic_wsdl**: This is the Web Service Description Language (WSDL) which describes how to communicate with the Epic interface.
- **epic_test_mode**: This tells the application to use a fake Epic server, rather than connecting to the Epic interface. This is primarily intended to be used in the test suite.

#### 2.5 Configuring RMID
Your institution may opt to use Research Master ID (RMID) to connect records between SPARCRequest and other systems, such as eIRB and Coeus.

##### RMID Configuration
- **research_master_enabled**: This determines whether SPARCRequest protocols will be connected with a research master record.
- **research_master_link**: This is the URL of your institution's RMID application.
- **research_master_api**: This is the URL of your institution's RMID API.
- **rmid_api_token**: This is the token used to access your institution's RMID API.

#### 2.6 SPARCFulfillment
Your institution may opt to use [SPARCFulfillment](https://github.com/sparc-request/sparc-fulfillment), aka Clinical Work Fulfillment (CWF) to allow service providers to fulfill and track the clinical and non-clinical services they provide.

- **clinical_work_fulfillment_url**: This is the URL of your institution's SPARCFulfillment application.
- **fulfillment_contingent_on_catalog_manager**: This determines whether users will have the ability to push a request to SPARCFulfillment from the Admin Dashboard.

#### 2.7 SPARCFunding
Your institution may opt to use the SPARCFunding module to keep track of funding opportunities.

- **use_funding_module**: This determines whether the application will use the SPARCFunding module.
- **funding_admins**: This is a list of users who will have full access to the SPARCFunding module.
- **funding_org_ids**: This is a list of organization ids that are offering SPARCFunding opportunities.

#### 2.8 SPARCRequest API
Your institution may opt to use the SPARCRequest API to communicate with external applications, such as SPARCFulfillment.

- **current_api_version**: This is the current version of the SPARCRequest API.
- **remote_service_notifier_protocol**: This is the HTTP protocol (HTTP/HTTPS) of the SPARCRequest API.
- **remote_service_notifier_username**: This is the authentication username of the SPARCRequest API.
- **remote_service_notifier_password**: This is the authentication password of the SPARCRequest API.
- **remote_service_notifier_host**: This is the host domain of the SPARCRequest API.
- **remote_service_notifier_path**: This is the URL path of the SPARCRequest API.

#### 2.9 Right Navigation

SPARCRequest provides various configurable help links below the service cart (AKA Right Navigation). These include Feedback, Frequently Asked Questions, Contact Us, and Short Interaction buttons.

##### "Feedback" Button
- **use_feedback_link**: This determines whether the application will use an external resource for users to provide feedback. This has lower precedence than `use_redcap_api` when both are enabled.
- **feedback_link**: This is the URL of the external resource for users to provide feedback.
- **use_redcap_api**: This determines whether the application will use a REDCap API for users to provide feedback. This has a higher precedence than `use_feedback_link` when both are enabled.
- **redcap_api_url**: This is the URL of your institution's REDCap API.
- **redcap_api_token**: This is the token used to access your institution's REDCap API.
- **feedback_mail_to**: This is the email that feedback will be sent to using the built-in feedback system.

##### "Help/FAQs" Button
- **use_faq_link**: This determines whether the application will use an external FAQs resource. When turned off, the application will instead display a modal with FAQs.
- **faq_url**: This is the URL of the external FAQs resource.

##### "Contact Us" Button
- **contact_us_department**: This is the name of the department that users may contact for assistance.
- **contact_us_phone**: This is the phone number for users to contact the department for assistance.
- **contact_us_mail_to**: This is the email that help messages will be sent to.
- **contact_us_cc**: This is the email(s) that will be CCed in help messages.

##### "Short Interaction" Button
- **use_short_interaction**: This determines whether the application will display the `Short Interaction` button.

#### 2.10 Google Calendar
Your institution may opt to integrate Google Calendar to display events on the SPARCRequest homepage.

- **use_google_calendar**: This determines whether Google Calendar events will be displayed on the homepage.
- **calendar_url**: This is the URL of the Google Calendar used to display events.
- **calendar_event_limit**: This is the maximum number of events that will be displayed in the homepage Calendar.

#### 2.11 News Feed
Your institution may opt to integrate an external blog to display posts in the news feed on the SPARCRequest homepage.

- **use_news_feed**: This determines whether a news feed of blog posts will be displayed on the homepage.
- **news_feed_url**: This is the URL used to retrieve news feed posts.
- **news_feed_post_limit**: This is the maximum number of posts that will be displayed in the homepage News Feed.

There are currently two ways to retrieve posts for the news feed - through an external API, or by parsing an HTML document for specific CSS selectors.

You may opt to use an external API to retrieve posts. Currently the application allows the use of an Atlassian Confluence API. If you wish to integrate new APIs, you will need to create an adapter in `app/lib/news_feed` that extends the `ApiAdapter` class. This adapter should be named `<YourAPIName>Adapter`, where `<YourAPIName>` is the value of the `news_feed_api` setting.

- **use_news_feed_api**: This determines whether the news feed will be retrieved using an external API. When disabled, the application will attempt to retrieve content through CSS selectors.
- **news_feed_api**: This is the name of the API to pull the news feed from. This name is used to find a corresponding adapter for that API.

Your API may require additional settings to be added in order to properly configure.

For an Atlassian Confluence API:
- **news_feed_atlassian_space**: This is the identifier for the Atlassian space that contains posts.

You may also opt to simply parse an HTML document for CSS selectors. This will be done by default if `use_news_feed_api` is set to `false`. Simply assign the CSS selectors for individual posts (generally some kind of container), title, link, and date.

- **news_feed_post_selector**: This is the CSS selector of a post at the news_feed_url to be used to gather data for the news feed.
- **news_feed_title_selector**: This is the CSS selector of a post's title at the news_feed_url to be used in the news feed.
- **news_feed_link_selector**: This is the CSS selector of a link to the post at the news_feed_url to be used in the news feed.
- **news_feed_date_selector**: This is the CSS selector of a post's date at the news_feed_url to be used in the news feed.

#### 2.12 Tableau
Your institution may opt to integrate a Tableau Dashboard on the SPARCRequest homepage. You will need to enable guest viewing access to allow user to view the dashboard without logging in. In addition, the Dashboard may need to be scaled to fit properly onto the homepage.

- **use_tableau**: This determines whether the application will display a Tableau dashboard on the homepage.
- **homepage_tableau_dashboard**: This is the name of the Tableau Dashboard to be displayed on the homepage.
- **homepage_tableau_url**: This is the URL of the Tableau Dashboard to be displayed on the homepage.


#### 2.13 System Satisfaction Survey
Your institution may opt to provide users with a system satisfaction survey prior to submitting a service request.

- **system_satisfaction_survey**: This determines whether the application will prompt users to fill out a system satisfaction survey prior to submitting a service request.
- **system_satisfaction_survey_cc**: This field will overwrite the system satisfaction survey mailers in the application to instead cc to this address. This is overwritten in development/testing/staging environments in order to prevent real emails from being sent out to general users.

#### 2.14 navigation.yml
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
Permissible Values are options and labels used across SPARCRequest, most of which can be customized for your institution. These are stored in the `permissible_values` database table and categorized by their `category` attribute.

The data that generates Permissible Values is stored in various CSV files located in `db/seeds/permissible_values/2.0.5` (see below for descriptions of the various types of Permissible Values). To customize these values for your institution, simply edit these files, then run the following rake task in your terminal:

```
rake:import_permissible_values
```

##### Protocol Options
These Permissible Values are used when creating or updating a Study or Project

- **funding_source**: These are the sources of funding for research that is already funded.
- **potential_funding_source**: These are the sources of funding for research that is still unfunded.
- **federal_grant_code**: These are the grant codes for Federally-funded research.
- **federal_grant_phs_sponsor**: These are a list of Policy for Public Health Service (PHS) sponsors for Federally-funded Protocols.
- **federal_grant_non_phs_sponsor**: These are a list of sponsors outside of the PHS for Federally-funded research.
- **submission_type**: These are the types of submissions for research using human subjects. _(Ex. Exempt, Expedited)_
- **study_type**: These are the types of research studies. _(Ex. Clinical Trials, Basic Science)_
- **impact_area**: These are the impact areas of a research study. _(Ex. Pediatrics, Diabetes, Cancer)_
- **affiliation_type**: These are organizations affiliated with the research study. _(Ex. Cancer Center, Oral Health COBRE)_

In addition to these values, you will also find a list of Study Phases in the `study_phases` database table.

##### Authorized User Options
These Permissible Values are used when creating or updating an Authorized User on a Study or Project.

- **user_role**: These are the roles of users of a Project or Study. We do not recommend changing these unless absolutely necessary as many are logic-driven and would require significant changes be made to the application if removed, such as Primary PI and PD/PI. _(Ex. PD/PI, Co-Investigator, Consultant)_
- **user_credential**: These are the credentials of users. _(Ex. MA, MD, PhD)_
- **subspecialty**: These are the subspecialties of users with rights to authorize or change study charges. _(Ex. Bioengineering, Cell Biology, Social Psychology)_
- **proxy_right**: These are the levels of user rights to a study or project. We do not recommend changing these unless absolutely necessary as many are logic-driven and would require significant changes be made to the application if removed.

##### General Options
- **status**: These are the statuses used by Service Requests and Sub Service Requests.
- **document_type**: These are the types of documents that can be added to a Protocol by a user. **_Note: These are not the allowed file extensions. Allowed file extensions can be found in `app/models/document.rb`._**
- **interaction_subject**: These are the subjects of a Short Interaction request.
- **interaction_type**: These are the methods of contact for a Short Interaction request.

#### 3.2 constants.yml
`config/constants.yml` contains a number of labels and environment settings. These should remain unchanged. Changing these could require substantial other changes throughout the application.

- **accordion_color_options**: This is a list of colors for displaying Institutions and Providers in the service catalog on the SPARCRequest homepage. These are selected in SPARCCatalog.
- **alert_statuses**: This is a list of statuses for alerts. Alerts can be used on a production server to warn you when an external component fails.
- **alert_types**: This is a list of types of alerts. Currently alerts are only used for the news feed and Google calendar on the homepage.
- **audit_actions**: This is a list of audit actions used in auditing reports.
- **epic_push_status_text**: This is a list containing various statuses of Protocols when being pushed to Epic.
- **epic_rights**: This is a list of Epic user rights for given to authorized users.
- **study_type_answers**: This list maps answers to the first version of study type questions to a corresponding study-type note. Each column corresponds to a different question. `true` maps to questions answered "yes", `false` to questions answered "no", and `~` to questions that will not be displayed in the sequence.
- **study_type_answers_version_2**: This list maps answers to the second version of study type questions to a corresponding study-type note. Each column corresponds to a different question. `true` maps to questions answered "yes", `false` to questions answered "no", and `~` to questions that will not be displayed in the sequence.
- **study_type_answers_version_3**: This list maps answers to the third version of study type questions to a corresponding study-type note. Each column corresponds to a different question. `true` maps to questions answered "yes", `false` to questions answered "no", and `~` to questions that will not be displayed in the sequence.
- **study_type_notes**: This is a list of study-type notes displayed based on a user's answers to study-type questions. These notes explain what each type of study means.
- **study_type_questions**: This is a list of the first version of study-type questions displayed to users when creating or updating a study.
- **study_type_questions_version_2**: This is a list of the second version of study-type questions displayed to users when creating or updating a study.
- **study_type_questions_version_3**: This is a list of the third version of study-type questions displayed to users when creating or updating a study.
- **browser_versions**: This is a list of browsers for when a user submits feedback via the built-in feedback system.


### 4. DotENV
SPARCRequest stores several environment variables specific to each institution. To access these variables, first you must create a `.env` file. The easiest way to do this is to copy the example file:

    cp dotenv.example .env
    
The environment variables are as follows:

- **site_name**: This is an optional name that will be displayed as an alert at the top of SPARCRequest. This can be useful for keeping track of the current environment.
- **SPARC_VERSION**: This is the version of SPARCRequest your institution is using and will be displayed in the footer of the application.
- **institution**: This is the name of your institution. This is currently only used for the CAS and Shibboleth login buttons.
- **institution_logo**: This is the path to your institution's logo image. This image should be placed in `app/assets/images` and should be 1206x791 pixels or a similar ratio.
- **org_logo**: This is the path to your organization's logo image. This image should be placed in `app/assets/images` and should be 300x140 pixels or a similar ratio.
- **time_zone**: This is the time zone for your application. You can find the correct time zone from [the Ruby on Rails docs](http://api.rubyonrails.org/v5.1/classes/ActiveSupport/TimeZone.html) or by running `rake time:zones:all`.

### 5. Localization
SPARCRequest uses the [I18n gem](http://guides.rubyonrails.org/i18n.html) which allows each institution to customize any text content throughout the application. All of the text content of a page can be found in one of the locales files found in `config/locales`. Each file contains text specific to the corresponding portion of the application, with shared values stored in `en.yml`.

If your institution wishes to use SPARCRequest in a language other than English, simply copy each `.en.yml` file and replace `en` with the identifier corresponding to the language. Then, replace the `en:` key in each file with the same identifier and translate the text as needed. Lastly, set the default locale in `config/application.rb`:

    config.18n.default_locale = :your_identifier

You can view a list of available locales by running the following command in your Rails Console:

    I18n.available_locales

### 6. Data Flags
#### 6.1 Organization Tags
An organization can be given tags to either aid in categorization, or to apply specific functionality.  A Catalog Manager can add whatever tags they would like for their own convenience, however there are some tags that ascribe specific functionality to any sub service requests that belong to that organization.  Tags are entered as a comma separated list such as:

    hospital, nursing, services

There are currently two tags which ascribe additional functionality:

- ctrc - Any organization that has this tag gets a set of features activated in the application which are unique to CTRC (Clinical and Translational Research Center -- aka GCRC) organizations, for instance the 'CTRC Approved' status for service requests.

Any _functional_ tags that your organization will need will need to have changes made in the codebase to take effect, otherwise they will simply be _non-functional_.

#### 6.2 Catalog Overlords
Catalog Overlord is an attribute on identities (which can be set to true or false) that determines whether a given identity, when accessing the catalog_manager, has the ability to check or uncheck the 'edit historic pricing' flag on catalog managers that have been assigned to organizations. If this flag is checked, then that identity will then be able to modify pricing maps/pricing setups that have display/effective dates in the past.

The catalog_overlord attribute is not able to be set within the application itself. It has to be done by a developer either through the rails console, or via direct SQL manipulation.
