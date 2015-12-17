$("#modal_area").html("<%= escape_javascript(render(partial: 'new', locals: { note: @note })) %>");
$("#modal_place").modal 'show'
$(".modal-content").find(":input").not("[type='hidden'],[type='button']").first().focus()
