begin 
  application_config ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]
  DEFAULT_MAIL_TO      = application_config['default_mail_to']
  ADMIN_MAIL_TO        = application_config['admin_mail_to']
  FEEDBACK_MAIL_TO     = application_config['feedback_mail_to']
  NEW_USER_CC          = application_config['new_user_cc']
  ROOT_URL             = application_config['root_url']
  USER_PORTAL_LINK     = application_config['user_portal_link']
  HEADER_LINK_1        = application_config['header_link_1']
  HEADER_LINK_2        = application_config['header_link_2']
  HEADER_LINK_3        = application_config['header_link_3']
  USE_INDIRECT_COST    = application_config['use_indirect_cost']
  USE_SHIBOLETH        = application_config['use_shiboleth']
  USE_LDAP             = application_config['use_ldap']
rescue
  raise "application.yml not found, see config/application.yml.example"
end

# Loads in and sets all the constants from the constants.yml file
begin
  constant_file                  = File.join(Rails.root, 'config', 'constants.yml')
  config                         = YAML::load_file(constant_file)
  AFFILIATION_TYPES              = config['affiliations']
  IMPACT_AREAS                   = config['impact_areas']
  STUDY_TYPES                    = config['study_types']
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
rescue
  raise "constants.yml not found"
end
