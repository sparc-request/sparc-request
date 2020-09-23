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

$ ->
  if $('.edit_doorkeeper_application').length
    updateUidAndSecret()

(exports ? this).updateUidAndSecret = () ->
  $uid    = $('#doorkeeper_application_uid')
  $secret = $('#doorkeeper_application_secret')
  uid     = $uid.val()
  secret  = $secret.val()
  $uid.remove()
  $secret.remove()

  $('#copyUID').on 'click', ->
    $this = $(this)

    if !$this.hasClass('copied')
      $this.addClass('copied btn-success').removeClass('btn-primary')
      $this.find('.copy-action').toggleClass('copy-action-hidden')
      copyToClipboard(uid)
      
      setTimeout (->
        $this.addClass('btn-primary').removeClass('btn-success copied')
        $this.find('.copy-action').toggleClass('copy-action-hidden')
      ), 1500  

  $('#revealSecret').on 'click', ->
    $('#revealSecret').replaceWith("<div class='text-muted'>#{secret}</div>")

  $('#copySecret').on 'click', ->
    $this = $(this)
    copyToClipboard(secret)

    if !$this.hasClass('copied')
      $this.addClass('copied btn-success').removeClass('btn-primary')
      $this.find('.copy-action').toggleClass('copy-action-hidden')
      
      setTimeout (->
        $this.addClass('btn-primary').removeClass('btn-success copied')
        $this.find('.copy-action').toggleClass('copy-action-hidden')
      ), 1500
