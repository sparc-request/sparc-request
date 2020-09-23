# Copyright © 2011-2020 MUSC Foundation for Research Development
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

Swal.fire(
  title: "Create an Application"
  input: 'text'
  inputAttributes: {
    placeholder: "Application Name"
  }
  showCloseButton: true
  confirmButtonText: I18n.t('actions.create')
  preConfirm: (name) ->
    $.ajax(
      type: 'post'
      dataType: 'script'
      url: '/admin/applications'
      data:
        doorkeeper_application:
          name:         $('.swal2-input').val()
          confidential: 'true'
    ).then( (data) ->
      $(".swal2-input").removeClass('is-invalid')
      $('#applicationsTable').bootstrapTable('refresh')
      id = JSON.parse(data).id
      Swal.fire(
        icon: 'success'
        title: "Application Created!"
        showCancelButton: false
        showConfirmButton: false
        timer: 1500
      ).then( ->
        window.location = "/admin/applications/#{id}/edit"
      )
    ).catch( (error) ->
      Swal.enableButtons()
      return false
    )
)
