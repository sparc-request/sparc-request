$(document).ready ->
  Sparc.project = {
    ready: ->
      display_dependencies=
        "#project_funding_status" :
          pending_funding    : ['#pending_funding']
          funded             : ['#funded']
      
      FormFxManager.registerListeners($('.edit-project-view'), display_dependencies)

      $('#project_funding_status').change ->
        $('#project_funding_source').val("")
        $('#project_potential_funding_source').val("")
        $('#project_funding_source').change()
        $('#project_potential_funding_source').change()
        $('#project_indirect_cost_rate').val("")

      $('#project_funding_source, #project_potential_funding_source').change ->
        switch $(this).val()
          when "internal", "college" then $('#project_indirect_cost_rate').val("0")
          when "industry", "foundation", "investigator" then $('#project_indirect_cost_rate').val("25")
          when "federal" then $('#project_indirect_cost_rate').val("49.5")
  }
