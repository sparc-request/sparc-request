# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

$ ->

  if $('.initial-budget-sponsor-received-date-picker').val() != ''
    $('.initial-amount').removeClass('hide')
    $('.initial-amount-cs').removeClass('hide')

  if $('.budget-agreed-upon-date-picker').val() != ''
    $('.negotiated-amount').removeClass('hide')
    $('.negotiated-amount-cs').removeClass('hide')

  $(document).on 'dp.change', '.start-date-picker', (e) ->
    $('.start-date-setter').val(e.date)

  $(document).on 'dp.change', '.end-date-picker', (e) ->
    $('.end-date-setter').val(e.date)

  $(document).on 'dp.change', '.recruitment-start-date-picker', (e) ->
    $('.recruitment-start-date-setter').val(e.date)

  $(document).on 'dp.change', '.recruitment-end-date-picker', (e) ->
    $('.recruitment-end-date-setter').val(e.date)

  $(document).on 'dp.change', '.initial-budget-sponsor-received-date-picker', (e) ->
    $('.initial-budget-sponsor-received-date-setter').val(e.date)

  $(document).on 'dp.change', '.budget-agreed-upon-date-picker', (e) ->
    $('.budget-agreed-upon-setter').val(e.date)

  $(document).on 'dp.hide', '.start-date-picker, .end-date-picker, .recruitment-start-date-picker, .recruitment-end-date-picker, .initial-budget-sponsor-received-date-picker, .budget-agreed-upon-date-picker', ->
    $('.milestone-form').submit()

  $(document).on 'blur', '.initial-amount, .negotiated-amount, .negotiated-amount-cs, .initial-amount-cs', ->
    $('.milestone-form').submit()

