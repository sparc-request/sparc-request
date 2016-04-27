# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Load the rails application
require File.expand_path('../application', __FILE__)

APP_CONFIG ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]

DEFAULT_MAIL_TO                           = APP_CONFIG['default_mail_to']
ADMIN_MAIL_TO                             = APP_CONFIG['admin_mail_to']
EPIC_RIGHTS_MAIL_TO                       = APP_CONFIG['approve_epic_rights_mail_to']
FEEDBACK_MAIL_TO                          = APP_CONFIG['feedback_mail_to']
NEW_USER_CC                               = APP_CONFIG['new_user_cc']
SYSTEM_SATISFACTION_SURVEY_CC             = APP_CONFIG['system_satisfaction_survey_cc']
ROOT_URL                                  = APP_CONFIG['root_url']
USER_PORTAL_LINK                          = APP_CONFIG['user_portal_link']
HEADER_LINK_1                             = APP_CONFIG['header_link_1']
HEADER_LINK_2                             = APP_CONFIG['header_link_2']
HEADER_LINK_3                             = APP_CONFIG['header_link_3']
USE_INDIRECT_COST                         = APP_CONFIG['use_indirect_cost']
USE_SHIBOLETH                             = APP_CONFIG['use_shiboleth']
USE_SHIBBOLETH_ONLY                       = APP_CONFIG['use_shibboleth_only']
USE_LDAP                                  = APP_CONFIG['use_ldap']
SUPPRESS_LDAP_FOR_USER_SEARCH             = APP_CONFIG['suppress_ldap_for_user_search'] || nil
USE_EPIC                                  = APP_CONFIG['use_epic']
QUEUE_EPIC                                = APP_CONFIG['queue_epic']
QUEUE_EPIC_LOAD_ERROR_TO                  = APP_CONFIG['queue_epic_load_error_to']
QUEUE_EPIC_EDIT_LDAP_UIDS                 = APP_CONFIG['queue_epic_edit_ldap_uids'] || []
EPIC_QUEUE_REPORT_TO                      = APP_CONFIG['epic_queue_report_to']
USE_GOOGLE_CALENDAR                       = APP_CONFIG['use_google_calendar']
USE_NEWS_FEED                             = APP_CONFIG['use_news_feed']
CALENDAR_URL                              = APP_CONFIG['calendar_url']
FAQ_URL                                   = APP_CONFIG['faq_url']
USE_FAQ_LINK                              = APP_CONFIG['use_faq_link'] || false
SEND_AUTHORIZED_USER_EMAILS               = APP_CONFIG['send_authorized_user_emails']
CUSTOM_ASSET_PATH                         = APP_CONFIG['custom_asset_path']
LOCALE_OVERRIDE                           = APP_CONFIG['locale_override']
CONSTANTS_YML_OVERRIDE                    = APP_CONFIG['constants_yml_override'] || ''
SYSTEM_SATISFACTION_SURVEY                = APP_CONFIG['system_satisfaction_survey'] || false
NO_REPLY_FROM                             = APP_CONFIG['no_reply_from']
EDITABLE_STATUSES                         = APP_CONFIG['editable_statuses'] || {}
REMOTE_SERVICE_NOTIFIER_PROTOCOL          = APP_CONFIG['remote_service_notifier_protocol']
REMOTE_SERVICE_NOTIFIER_HOST              = APP_CONFIG['remote_service_notifier_host']
REMOTE_SERVICE_NOTIFIER_PATH              = APP_CONFIG['remote_service_notifier_path']
REMOTE_SERVICE_NOTIFIER_USERNAME          = APP_CONFIG['remote_service_notifier_username']
REMOTE_SERVICE_NOTIFIER_PASSWORD          = APP_CONFIG['remote_service_notifier_password']
HOST                                      = APP_CONFIG['host']
CURRENT_API_VERSION                       = APP_CONFIG['current_api_version']
BUG_ENHANCEMENT_URL                       = APP_CONFIG['bug_enhancement_url'] || nil
CLINICAL_WORK_FULFILLMENT_URL             = APP_CONFIG['clinical_work_fulfillment_url'] || nil
FULFILLMENT_CONTINGENT_ON_CATALOG_MANAGER = APP_CONFIG['fulfillment_contingent_on_catalog_manager'] || nil
USE_ABOUT_SPARC_LINK                      = APP_CONFIG['use_about_sparc_link'] || false
CREATE_AN_ACCOUNT                         = APP_CONFIG['create_an_account']
ABOUT_SPARC_URL                           = APP_CONFIG['about_sparc_url'] || nil
USE_CAS_ONLY                              = APP_CONFIG['use_cas_only']
USE_CAS                                   = APP_CONFIG['use_cas']
INSTITUTION_NAME                          = APP_CONFIG['institution_name'] || "University"

APP_CONSTANT ||= YAML::load_file(File.join(Rails.root, 'config', 'constants'+CONSTANTS_YML_OVERRIDE+'.yml'))

# Loads in and sets all the constants from the constants.yml file
begin

  AFFILIATION_TYPES              = APP_CONSTANT['affiliations']
  IMPACT_AREAS                   = APP_CONSTANT['impact_areas']
  EPIC_RIGHTS                    = APP_CONSTANT['epic_rights']
  EPIC_RIGHTS_INFO               = APP_CONSTANT['epic_rights_info']
  EPIC_PUSH_STATUS_TEXT          = APP_CONSTANT['epic_push_status_text']
  STUDY_TYPES                    = APP_CONSTANT['study_types']
  STUDY_TYPE_QUESTIONS           = APP_CONSTANT['study_type_questions']
  STUDY_TYPE_QUESTIONS_VERSION_2 = APP_CONSTANT['study_type_questions_version_2']
  STUDY_TYPE_ANSWERS             = APP_CONSTANT['study_type_answers']
  STUDY_TYPE_ANSWERS_VERSION_2   = APP_CONSTANT['study_type_answers_version_2']
  FUNDING_STATUSES               = APP_CONSTANT['funding_statuses']
  ACCORDION_COLOR_OPTIONS        = APP_CONSTANT['accordion_color_options']
  PROXY_RIGHTS                   = APP_CONSTANT['proxy_rights']
  FUNDING_SOURCES                = APP_CONSTANT['funding_sources']
  POTENTIAL_FUNDING_SOURCES      = APP_CONSTANT['potential_funding_sources']
  FEDERAL_GRANT_CODES            = APP_CONSTANT['federal_grant_codes']
  FEDERAL_GRANT_PHS_SPONSORS     = APP_CONSTANT['federal_grant_phs_sponsors']
  FEDERAL_GRANT_NON_PHS_SPONSORS = APP_CONSTANT['federal_grant_non_phs_sponsors']
  SUBMISSION_TYPES               = APP_CONSTANT['submission_types']
  SUBSPECIALTIES                 = APP_CONSTANT['subspecialties']
  USER_ROLES                     = APP_CONSTANT['user_roles']
  STUDY_PHASES                   = APP_CONSTANT['study_phases']
  DOCUMENT_TYPES                 = APP_CONSTANT['document_types']
  INSTITUTIONS                   = APP_CONSTANT['institutions']
  COLLEGES                       = APP_CONSTANT['colleges']
  DEPARTMENTS                    = APP_CONSTANT['departments']
  USER_CREDENTIALS               = APP_CONSTANT['user_credentials']
  AVAILABLE_STATUSES             = APP_CONSTANT['available_statuses']
  DEFAULT_STATUSES               = APP_CONSTANT['default_statuses']
  SUBJECT_ETHNICITIES            = APP_CONSTANT['subject_ethnicities']
  SUBJECT_GENDERS                = APP_CONSTANT['subject_genders']
  AUDIT_ACTIONS                  = APP_CONSTANT['audit_actions']
  ALERT_TYPES                    = APP_CONSTANT['alert_types']
  ALERT_STATUSES                 = APP_CONSTANT['alert_statuses']
rescue
  raise "constants.yml not found"
end

# Initialize the rails application
SparcRails::Application.initialize!

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144
end
