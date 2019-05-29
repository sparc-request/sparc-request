// This file has to be required before rails-ujs
// To use it change `data-confirm` of your links to `data-confirm-swal`
(function() {
  const handleConfirm = function(element) {
    if (!allowAction(this)) {
      Rails.stopEverything(element)
    }
  }

  const allowAction = element => {
    if (element.getAttribute('data-confirm-swal') === null) {
      return true
    }

    showConfirmationDialog(element)
    return false
  }

  // Display the confirmation dialog
  const showConfirmationDialog = element => {
    const title = element.getAttribute('data-title');
    const html = element.getAttribute('data-html');
    const type = element.getAttribute('data-type');
    const confirmText = element.getAttribute('data-confirm-text');
    const cancelText = element.getAttribute('data-cancel-text');
    const customClass = element.getAttribute('data-class');

    swal({
      title: title || I18n.t('confirm.title'),
      html: html || I18n.t('confirm.text'),
      type: type === null ? 'warning' : type,
      showCancelButton: true,
      confirmButtonText: confirmText || I18n.t('confirm.confirm'),
      confirmButtonClass: 'btn btn-lg btn-primary mr-1',
      cancelButtonText: cancelText || I18n.t('confirm.cancel'),
      cancelButtonClass: 'btn btn-lg btn-secondary ml-1',
      buttonsStyling: false,
      customClass: customClass || ''
    }).then(result => confirmed(element, result))
  }

  const confirmed = (element, result) => {
    if (result.value) {
      // User clicked confirm button
      $.ajax({
        method: element.getAttribute('data-method') || 'GET',
        url: (element.getAttribute('tagName') === 'A' && element.getAttribute('href') !== 'javascript:void(0)') ? element.getAttribute('href') : element.getAttribute('data-url'),
        dataType: (element.getAttribute('tagName') === 'A' && element.getAttribute('href') !== 'javascript:void(0)' && element.getAttribute('data-remote') !== 'true') ? 'html' : 'script',
        data: {
          authenticity_token: $('meta[name=csrf-token]').attr('content')
        }
      });
    }
  }

  // Hook the event before the other rails events so it works togeter
  // with `method: :delete`.
  // See https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts/rails-ujs/start.coffee#L69
  document.addEventListener('rails:attachBindings', element => {
    Rails.delegate(document, '[data-confirm-swal]', 'click', handleConfirm)
  })

}).call(this)
