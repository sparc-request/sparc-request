$(document).ready ->
  display_dependencies=
    "#study_funding_status" :
      pending_funding    : ['#pending_funding']
      funded             : ['.funded']
    "#study_potential_funding_source" :
      internal           : ['.internal_funded_pilot_project']
    "#study_funding_source" :
      federal            : ['.federal']
      internal           : ['.internal_funded_pilot_project']
    '#study_research_types_attributes_human_subjects' :
      'true'             : ['.hr_number', '.pro_number', '.irb_of_record', '.submission_type',
                            '.irb_approval_date', '.irb_expiration_date']
    '#study_research_types_attributes_vertebrate_animals' :
      'true'             : ['.iacuc_number', '.name_of_iacuc', '.iacuc_approval_date',
                            '.iacuc_expiration_date']
    '#study_research_types_attributes_investigational_products' :
      'true'             : ['.ind_number', '.ide_number']
    '#study_research_types_attributes_ip_patents':
      'true'             : ['.patent_number', '.inventors']

  FormFxManager.registerListeners($('.edit-project-view'), display_dependencies)

  autoComplete = $('#user_search_term').autocomplete
    source: '/search/identities'
    minLength: 3
    search: (event, ui) ->
      #$('.user-search-clear-icon').remove()
      $("#user_search_term").after('<img src="/assets/spinner.gif" class="user-search-spinner" />')
    open: (event, ui) ->
      $('.user-search-spinner').remove()
      $("#user_search_term").after('<img src="/assets/clear_icon.png" class="user-search-clear-icon" />')
    close: (event, ui) ->
      $('.user-search-spinner').remove()
      #$('.user-search-clear-icon').remove()
    select: (event, ui) ->
      console.log ui
      console.log event
      console.log 'i was selected'

  .data("autocomplete")._renderItem = (ul, item) ->
    if item.label == 'No Results'
      $("<li class='search_result'></li>")
      .data("item.autocomplete", item)
      .append("#{item.label}")
      .appendTo(ul)
    else
      $("<li class='search_result'></li>")
      .data("item.autocomplete", item)
      .append("<a>" + item.label + "</a>")
      .appendTo(ul)

  user_details_dependencies=
    '#role' :
      pi                        : ['.era_commons_name', '.subspecialty']
      'co-investigator'         : ['.era_commons_name', '.subspecialty']
      'faculty-collaborator'    : ['.era_commons_name', '.subspecialty']
      consultant                : ['.era_commons_name', '.subspecialty']
      "staff-scientist"         : ['.era_commons_name', '.subspecialty']
      postdoc                   : ['.era_commons_name', '.subspecialty']
      mentor                    : ['.era_commons_name', '.subspecialty']
      other                     : ['.role_other']
    '#credentials' :
      other          : ['.credentials_other']

  FormFxManager.registerListeners($('.user-details'), user_details_dependencies)
