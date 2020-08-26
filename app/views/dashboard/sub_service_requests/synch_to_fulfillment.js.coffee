<% @sub_service_request.reload %>
$('#studyLevelActivitiesTable').bootstrapTable('refresh')

# Re-render Admin Edit SSR header
$("#subServiceRequestSummary").replaceWith("<%= j render 'dashboard/sub_service_requests/header', sub_service_request: @sub_service_request %>")