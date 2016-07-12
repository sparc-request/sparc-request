$(".tab-content [data-partial-name='<%= escape_javascript(@partial_name) %>']").html("<%= escape_javascript(render(partial: ('dashboard/' + @partial_name), locals: { tab: 'status_changes', user: @user, service_request: @service_request, sub_service_request: @sub_service_request, protocol: @protocol })) %>")
$("li.ss_tab.active a").click()
$(".bootstrap_table").bootstrapTable()
$(".datetimepicker").datetimepicker(format: 'MM/DD/YYYY', allowInputToggle: true)
