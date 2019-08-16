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
$('#modalContainer').html("<%= j render 'setup', report: @report %>")
$("#modalContainer").modal('show')
first_dependency = "#" + $('.reporting-field.has-dependencies').attr('id')
window.disable_deps(first_dependency)

if $('.from-date').length && $('.to-date').length
  startDate = $('.from-date').data().date
  endDate   = $('.to-date').data().date

  if startDate
    $('.to-date').datetimepicker('minDate', startDate)
    if !endDate
      $('.to-input').val('')

  $('.from-date').on 'change.datetimepicker', ->
    startDate = $('.from-input').val()
    endDate   = $('.to-input').val()

    if startDate
      $('.to-date').datetimepicker('minDate', startDate)
      $('.to-input').focus()
      if !endDate
        $('.to-input').val(startDate).blur().focus()
    else
      $('.to-date').datetimepicker('minDate', false)

  $('.to-input').on 'click', ->
    if (startDate = $('.from-input').val()) && !$(this).val()
      $(this).val(startDate).blur().focus()
