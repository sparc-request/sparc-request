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

$(document).ready ->
  $(document).on 'click', '.add-subsidy-button', ->
    data =
      'sub_service_request_id': $(this).data('ssrid'),
      'admin'                 : $(this).data('admin')
    $.ajax
      type: 'GET'
      url:  "/dashboard/subsidies/new"
      data: data

  $(document).on 'click', '.edit-subsidy-button', ->
    id = $(this).data('subsidy-id')
    data = 'admin' : $(this).data('admin')
    $.ajax
      type: 'GET'
      url:  "/dashboard/subsidies/#{id}/edit"
      data: data

  $(document).on 'click', '.delete-subsidy-button', ->
    subsidy_id = $(this).data('subsidy-id')

    if confirm(I18n['subsidies']['delete_confirm'])
      $.ajax
        type: 'DELETE'
        url: "/dashboard/subsidies/#{subsidy_id}"

  $(document).on 'click', '#approve-subsidy-button', ->
    id = $(this).data('subsidy-id')
    $.ajax
      type: 'PATCH'
      url:  "/dashboard/subsidies/#{id}/approve"

  $(document).on 'click', '#details-tab', ->
    $("#pending_subsidy").load(location.href + " #pending_subsidy")
