$("#modal_area").html("<%= escape_javascript(render(:partial =>'portal/admin/fulfillment_accordion/admin_approvals', locals: { sub_service_request: @sub_service_request })) %>");
$("#modal_place").modal 'show'
