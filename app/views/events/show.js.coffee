$('#modalContainer').html("<%= j render 'events/event_modal', event: @event %>")
$('#modalContainer').modal('show')
