$(document).ready ->

  display_dependencies=
    "#protocol_funding_status" :
      pending_funding    : ['#pending_funding']
      funded             : ['.funded']
    "#protocol_potential_funding_source" :
      internal           : ['.internal_funded_pilot_project']
    "#protocol_funding_source" :
      federal            : ['.federal']
      internal           : ['.internal_funded_pilot_project']
    'research_types[human_subjects]' :
      'true'             : ['.hr_number', '.pro_number', '.irb_of_record', '.submission_type',
                            '.irb_approval_date', '.irb_expiration_date']
    'research_types[vertebrate_animals]' :
      'true'             : ['.iacuc_number', '.name_of_iacuc', '.iacuc_approval_date',
                            '.iacuc_expiration_date']
    'research_types[investigational_products]' :
      'true'             : ['.ind_number', '.ide_number']
    'research_types[ip_patents]':
      'true'             : ['.patent_number', '.inventors']

  FormFxManager.registerListeners($('.edit-project-view'), display_dependencies)
