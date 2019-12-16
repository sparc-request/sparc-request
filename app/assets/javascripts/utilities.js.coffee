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

VALID_MONETARY_KEYS = [
  8, # backspace
  37, 38, 39, 40, # arrow keys
  46, # Delete
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, # 0-9
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, # numpad 0-9
  110, # decimal
  190 # period
]

(exports ? this).validateMonetaryInput = (e) ->
  charCode = if e.which then e.which else event.keyCode
  element  = e.target

  # dont allow multiple decimal points
  if (charCode == 110 || charCode == 190) && $(element).val().indexOf('.') >= 0
    e.preventDefault()

  # make sure only valid keys are allowed
  if !VALID_MONETARY_KEYS.includes(charCode)
    e.preventDefault()

(exports ? this).formatMoney = (n, t=',', d='.', c='$') ->
  s = if n < 0 then "-#{c}" else c
  i = Math.abs(n).toFixed(2)
  j = (if (i.length > 3 && i > 0) then i.length % 3 else 0)
  s += i.substr(0, j) + t if j
  return s + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t)

(exports ? this).humanize_string = (string) ->
  new_str = ''
  arr     = string.split('_')
  for word in arr
    new_str += word.charAt(0).toUpperCase() + word.slice(1) + ' '
  return new_str

(exports ? this).dateSorter = (a, b) ->
  if !a && !b
    return 0
  else if a && !b
    return 1
  else if !a && b
    return -1
  else
    sort_a = new Date($(a).text())
    sort_b = new Date($(b).text())
    return 1 if sort_a > sort_b
    return -1 if sort_a < sort_b
    return 0

(exports ? this).escapeHTML = (text) ->
  if text
    return text.replace(/&/g,'&amp;' ).replace(/</g,'&lt;').
      replace(/"/g,'&quot;').replace(/'/g,'&#039;')
  else
    return text
