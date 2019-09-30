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

(function($) {
  $.extend($.fn.modal.Constructor.Default, { backdrop: 'static' });

  $(document).ready( function() {
    $(document).on('hide.bs.popover', '[data-toggle="popover"][data-trigger="hover"]', event => {
      var $this = $(event.target);

      if ($(`.popover:hover`).length) {
        event.preventDefault();

        $('.popover').on('mouseleave', event => {
          $this.popover('hide')
        })
      }
    })

    $(document).on('click', '.nav-pills .nav-link:not(.active)', event => {
      $this = $(event.target)
      $this.parents('.nav-pills').find('.nav-link.active').removeClass('active');
      $this.addClass('active');
    })

    $(document).on('click', 'table.table-interactive tbody tr', event => {
      el = event.target

      if (el.tagName == 'tr') {
        window.location = $(el).find('a').first().attr('href');
      } else if (el.tagName != 'a') {
        window.location = $(el).parents('tr').find('a').first().attr('href');
      }
    })
  })
})(jQuery);

