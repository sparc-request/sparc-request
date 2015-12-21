$("#fulfillments_row").attr('data-line_item_id', "<%= @line_item.id %>")
$("#fulfillments_row").html("<%= escape_javascript(render(:partial =>'portal/study_level_activities/fulfillments_table', locals: {line_item: @line_item})) %>");
$("#fulfillments_row").prev("tr").first().find(".otf_fulfillments > .glyphicon").removeClass("glyphicon-refresh").addClass("glyphicon-chevron-down").parents("button").attr('data-original-title', 'Hide Fulfillments')
$("#fulfillments-table").bootstrapTable()
