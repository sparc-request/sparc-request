$(document).ready ->
  $('#project_funding_source').change ->
    switch $(this).val()
      when "internal", "college" then $('#project_indirect_cost_rate').val("0")
      when "industry", "foundation", "investigator" then $('#project_indirect_cost_rate').val("25")
      when "federal" then $('#project_indirect_cost_rate').val("47.5")