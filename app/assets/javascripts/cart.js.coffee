
# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Functions for manipulating the Services cart.
window.cart =
  selectService: (id) ->
    has_protocol = parseInt($('#has_protocol').val())
    li_count = parseInt($('#line_item_count').val())

    if has_protocol == 0 && li_count == 0
      $('#modal_place').html($('#new-request-modal').html())
      $('#modal_place').modal('show')
      $('#modal_place .yes-button').on 'click', (e) ->
        $.ajax
          type: 'POST'
          url: "/service_request/add_service/#{id}"
          data:
            srid: getSRId()
    else
      $.ajax
        type: 'POST'
        url: "/service_request/add_service/#{id}"
        data:
            srid: getSRId()

  removeService: (id, move_on, spinner) ->
    $.ajax
      type: 'DELETE'
      url: "/service_request/remove_service/#{id}?srid=#{getSRId()}"
      success: (data, textStatus, jqXHR) ->
        if move_on
          window.location = '/dashboard'
        else
          spinner.hide()

$(document).ready ->
  $(document).on 'click', '.cart-toggle .btn', ->
    tab = $(this).data('tab')
    if !$(this).hasClass('active')
      $(this).addClass('active' )
      $(this).siblings('.btn').removeClass('active')
      $('.ssr-tab').addClass('hidden')
      if tab == 'active'
        $('.active-ssrs').removeClass('hidden')
      else if tab == 'complete'
        $('.complete-ssrs').removeClass('hidden')
    return false

  $(document).on 'click', '.add-service', ->
    window.cart.selectService($(this).data('id'))

  $(document).on 'click', '.remove-service', ->
    id = $(this).data('id')
    li_count = parseInt($('#line_item_count').val())
    request_submitted = $(this).data('request-submitted')
    spinner = $('<span class="spinner"><img src="/assets/catalog_manager/spinner_small.gif"/></span>')

    if request_submitted == 1
      button = $(this)
      $('#modal_place').html($('#request-submitted-modal').html())
      $('#modal_place').modal('show')

      $('#modal_place .yes-button').on 'click', (e) ->
        button.replaceWith(spinner)
        window.cart.removeService(id, false, spinner)
    else if li_count == 1 && window.location.pathname != '/' && window.location.pathname.indexOf('catalog') == -1
      # Do not allow the user to remove the last service except in the catalog
      $('#modal_place').html($('#line-item-required-modal').html())
      $('#modal_place').modal('show')
    else
      $(this).replaceWith(spinner)
      window.cart.removeService(id, false, spinner)
