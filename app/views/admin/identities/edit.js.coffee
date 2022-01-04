$("#modalContainer").html("<%= j render 'admin/identities/form', identity: @identity %>")
$("#modalContainer").modal('show')

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
