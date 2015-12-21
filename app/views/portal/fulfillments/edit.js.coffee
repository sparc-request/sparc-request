$("#modal_area").html("<%= escape_javascript(render(:partial =>'study_level_activities/fulfillment_form', locals: {line_item: @line_item, fulfillment: @fulfillment, clinical_providers: @clinical_providers, header_text: 'Edit Fulfillment'})) %>");
$("#modal_place").modal 'show'
$("#date_fulfilled_field").datetimepicker(format: 'MM-DD-YYYY')
$(".selectpicker").selectpicker()
