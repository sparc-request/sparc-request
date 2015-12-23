$("#modal_place").html("<%= escape_javascript(render(partial: 'index', locals: { notes: @notes, notable: @notable, notable_type: @notable_type })) %>")
$("#modal_place").modal 'show'
