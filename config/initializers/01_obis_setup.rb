# Copyright © 2011-2017 MUSC Foundation for Research Development
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

if wkhtmltopdf_location = Setting.find_by_key('wkhtmltopdf_location').try(:value)
  # Setup PDFKit
  PDFKit.configure do |config|
    config.wkhtmltopdf = wkhtmltopdf_location
  end
end

# Loads in and sets all the constants from the constants.yml file
begin
  constant_file                  = File.join(Rails.root, 'config', 'constants.yml')
  config                         = YAML::load_file(constant_file)
  ADDITIONAL_DETAIL_QUESTION_TYPES = config['additional_detail_question_types']
  AFFILIATION_TYPES              = config['affiliations']
  BROWSER_VERSIONS               = config['browser_versions']
  IMPACT_AREAS                   = config['impact_areas']
  EPIC_RIGHTS                    = config['epic_rights']
  EPIC_RIGHTS_INFO               = config['epic_rights_info']
  EPIC_PUSH_STATUS_TEXT          = config['epic_push_status_text']
  STUDY_TYPES                    = config['study_types']
  STUDY_TYPE_QUESTIONS           = config['study_type_questions']
  STUDY_TYPE_QUESTIONS_VERSION_2 = config['study_type_questions_version_2']
  STUDY_TYPE_QUESTIONS_VERSION_3 = config['study_type_questions_version_3']
  STUDY_TYPE_ANSWERS             = config['study_type_answers']
  STUDY_TYPE_ANSWERS_VERSION_2   = config['study_type_answers_version_2']
  STUDY_TYPE_ANSWERS_VERSION_3   = config['study_type_answers_version_3']
  STUDY_TYPE_NOTES               = config['study_type_notes']
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
