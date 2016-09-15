# Copyright © 2011-2016 MUSC Foundation for Research Development
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

begin
  application_config ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]

  DEFAULT_MAIL_TO                           = application_config['default_mail_to']
  ADMIN_MAIL_TO                             = application_config['admin_mail_to']
  EPIC_RIGHTS_MAIL_TO                       = application_config['approve_epic_rights_mail_to']
  FEEDBACK_MAIL_TO                          = application_config['feedback_mail_to']
  NEW_USER_CC                               = application_config['new_user_cc']
  SYSTEM_SATISFACTION_SURVEY_CC             = application_config['system_satisfaction_survey_cc']
  ROOT_URL                                  = application_config['root_url']
  DASHBOARD_LINK                            = application_config['dashboard_link']
  HEADER_LINK_1                             = application_config['header_link_1']
  HEADER_LINK_2                             = application_config['header_link_2']
  HEADER_LINK_3                             = application_config['header_link_3']
  USE_INDIRECT_COST                         = application_config['use_indirect_cost']
  USE_SHIBBOLETH                             = application_config['use_shiboleth']
  USE_SHIBBOLETH_ONLY                       = application_config['use_shibboleth_only']
  USE_LDAP                                  = application_config['use_ldap']
  SUPPRESS_LDAP_FOR_USER_SEARCH             = application_config['suppress_ldap_for_user_search'] || nil
  USE_EPIC                                  = application_config['use_epic']
  QUEUE_EPIC                                = application_config['queue_epic']
  QUEUE_EPIC_LOAD_ERROR_TO                  = application_config['queue_epic_load_error_to']
  QUEUE_EPIC_EDIT_LDAP_UIDS                 = application_config['queue_epic_edit_ldap_uids'] || []
  EPIC_QUEUE_REPORT_TO                      = application_config['epic_queue_report_to']
  USE_GOOGLE_CALENDAR                       = application_config['use_google_calendar']
  USE_NEWS_FEED                             = application_config['use_news_feed']
  CALENDAR_URL                              = application_config['calendar_url']
  FAQ_URL                                   = application_config['faq_url']
  USE_FAQ_LINK                              = application_config['use_faq_link'] || false
  SEND_AUTHORIZED_USER_EMAILS               = application_config['send_authorized_user_emails']
  CUSTOM_ASSET_PATH                         = application_config['custom_asset_path']
  LOCALE_OVERRIDE                           = application_config['locale_override']
  CONSTANTS_YML_OVERRIDE                    = application_config['constants_yml_override'] || ''
  SYSTEM_SATISFACTION_SURVEY                = application_config['system_satisfaction_survey'] || false
  NO_REPLY_FROM                             = application_config['no_reply_from']
  EDITABLE_STATUSES                         = application_config['editable_statuses'] || {}
  REMOTE_SERVICE_NOTIFIER_PROTOCOL          = application_config['remote_service_notifier_protocol']
  REMOTE_SERVICE_NOTIFIER_HOST              = application_config['remote_service_notifier_host']
  REMOTE_SERVICE_NOTIFIER_PATH              = application_config['remote_service_notifier_path']
  REMOTE_SERVICE_NOTIFIER_USERNAME          = application_config['remote_service_notifier_username']
  REMOTE_SERVICE_NOTIFIER_PASSWORD          = application_config['remote_service_notifier_password']
  HOST                                      = application_config['host']
  CURRENT_API_VERSION                       = application_config['current_api_version']
  BUG_ENHANCEMENT_URL                       = application_config['bug_enhancement_url'] || nil
  CLINICAL_WORK_FULFILLMENT_URL             = application_config['clinical_work_fulfillment_url'] || nil
  FULFILLMENT_CONTINGENT_ON_CATALOG_MANAGER = application_config['fulfillment_contingent_on_catalog_manager'] || nil
  USE_ABOUT_SPARC_LINK                      = application_config['use_about_sparc_link'] || false
  CREATE_AN_ACCOUNT                         = application_config['create_an_account']
  ABOUT_SPARC_URL                           = application_config['about_sparc_url'] || nil
  USE_FEEDBACK_LINK                         = application_config['use_feedback_link'] || false
  NAVBAR_LINKS                              = application_config['navbar_links'] || {}

  if LOCALE_OVERRIDE
    I18n.available_locales = [:en, LOCALE_OVERRIDE]
    I18n.default_locale = LOCALE_OVERRIDE
    I18n.locale = LOCALE_OVERRIDE
  end

  if application_config.include?('wkhtmltopdf_location')
    # Setup PDFKit
    PDFKit.configure do |config|
      config.wkhtmltopdf = application_config['wkhtmltopdf_location']
    end
  end

rescue
  raise "application.yml not found, see config/application.yml.example"
end

# Loads in and sets all the constants from the constants.yml file
begin
  constant_file                  = File.join(Rails.root, 'config', 'constants'+CONSTANTS_YML_OVERRIDE+'.yml')
  config                         = YAML::load_file(constant_file)
  ADDITIONAL_DETAIL_QUESTION_TYPES = config['additional_detail_question_types']
  AFFILIATION_TYPES              = config['affiliations']
  IMPACT_AREAS                   = config['impact_areas']
  EPIC_RIGHTS                    = config['epic_rights']
  EPIC_RIGHTS_INFO               = config['epic_rights_info']
  EPIC_PUSH_STATUS_TEXT          = config['epic_push_status_text']
  STUDY_TYPES                    = config['study_types']
  STUDY_TYPE_QUESTIONS           = config['study_type_questions']
  STUDY_TYPE_QUESTIONS_VERSION_2 = config['study_type_questions_version_2']
  STUDY_TYPE_ANSWERS             = config['study_type_answers']
  STUDY_TYPE_ANSWERS_VERSION_2   = config['study_type_answers_version_2']
  FUNDING_STATUSES               = config['funding_statuses']
  ACCORDION_COLOR_OPTIONS        = config['accordion_color_options']
  PROXY_RIGHTS                   = config['proxy_rights']
  FUNDING_SOURCES                = config['funding_sources']
  POTENTIAL_FUNDING_SOURCES      = config['potential_funding_sources']
  FEDERAL_GRANT_CODES            = config['federal_grant_codes']
  FEDERAL_GRANT_PHS_SPONSORS     = config['federal_grant_phs_sponsors']
  FEDERAL_GRANT_NON_PHS_SPONSORS = config['federal_grant_non_phs_sponsors']
  SUBMISSION_TYPES               = config['submission_types']
  SUBSPECIALTIES                 = config['subspecialties']
  USER_ROLES                     = config['user_roles']
  STUDY_PHASES                   = config['study_phases']
  DOCUMENT_TYPES                 = config['document_types']
  INSTITUTIONS                   = config['institutions']
  COLLEGES                       = config['colleges']
  DEPARTMENTS                    = config['departments']
  USER_CREDENTIALS               = config['user_credentials']
  AVAILABLE_STATUSES             = config['available_statuses']
  DEFAULT_STATUSES               = config['default_statuses']
  SUBJECT_ETHNICITIES            = config['subject_ethnicities']
  SUBJECT_GENDERS                = config['subject_genders']
  AUDIT_ACTIONS                  = config['audit_actions']
  ALERT_TYPES                    = config['alert_types']
  ALERT_STATUSES                 = config['alert_statuses']
rescue
  raise "constants.yml not found"
end