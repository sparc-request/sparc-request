// Copyright © 2011-2019 MUSC Foundation for Research Development
// All rights reserved.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided with the distribution.

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// This file has to be required before rails-ujs
// To use it change `data-confirm` of your links to `data-confirm-swal`

(function() {
  window.handleConfirm = function(element) {
    var target = this.tagName === 'A' ? this : element;
    if (!allowAction(target) && this.tagName === 'A') {
      Rails.stopEverything(element)
    }
  }

  const allowAction = element => {
    if (element.getAttribute('data-confirm-swal') !== 'true') {
      return true
    }

    showConfirmationDialog(element)
    return false
  }

  // Display the confirmation dialog
  const showConfirmationDialog = element => {
    var title = element.getAttribute('data-title');
    var text = element.getAttribute('data-text');
    var html = element.getAttribute('data-html');
    var type = element.getAttribute('data-type');
    var confirmText = element.getAttribute('data-confirm-text');
    var cancelText = element.getAttribute('data-cancel-text');
    var customClass = element.getAttribute('data-class');

    Swal.fire({
      title: title || I18n.t('confirm.title') || "Are you sure?",
      text: text || (html ? "" : (I18n.t('confirm.text') || "This action cannot be undone.")),
      html: html || "",
      type: type === null ? 'warning' : type,
      showCancelButton: true,
      confirmButtonText: confirmText || I18n.t('confirm.confirm') || "Yes",
      confirmButtonClass: 'btn btn-lg btn-primary mr-1',
      cancelButtonText: cancelText || I18n.t('confirm.cancel') || "No",
      cancelButtonClass: 'btn btn-lg btn-secondary ml-1',
      buttonsStyling: false,
      customClass: customClass || ''
    }).then(result => confirmed(element, result))
  }

  const confirmed = (element, result) => {
    // User clicked confirm button
    if (result.value) {
      var method  = element.getAttribute('data-method');
      var tagName = element.tagName;
      var href    = element.getAttribute('href');
      var url     = element.getAttribute('data-url');
      var remote  = element.getAttribute('data-remote');

      if (tagName === 'A' && href !== 'javascript:void(0)' && remote !== 'true') {
        window.location = href;
        NProgress.start();
      } else {
        $.ajax({
          method: method || 'GET',
          url: (tagName === 'A' && href !== 'javascript:void(0)') ? href : url,
          dataType: 'script',
          data: {
            authenticity_token: $('meta[name=csrf-token]').attr('content')
          }
        });
      }
    }
  }

  // Hook the event before the other rails events so it works togeter
  // with `method: :delete`.
  // See https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts/rails-ujs/start.coffee#L69
  document.addEventListener('rails:attachBindings', element => {
    Rails.delegate(document, '[data-confirm-swal]', 'click', handleConfirm)
  })

}).call(this)
