$(document).ready ->
  user_details_dependencies=
    '#project_role_role' :
      pi                        : ['.era_commons_name', '.subspecialty']
      'co-investigator'         : ['.era_commons_name', '.subspecialty']
      'faculty-collaborator'    : ['.era_commons_name', '.subspecialty']
      consultant                : ['.era_commons_name', '.subspecialty']
      "staff-scientist"         : ['.era_commons_name', '.subspecialty']
      postdoc                   : ['.era_commons_name', '.subspecialty']
      mentor                    : ['.era_commons_name', '.subspecialty']
      other                     : ['.role_other']
    '#identity_credentials' :
      other          : ['.credentials_other']

  FormFxManager.registerListeners($('.user-details'), user_details_dependencies)
