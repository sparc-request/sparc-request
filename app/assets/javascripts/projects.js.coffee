# Copyright © 2011-2016 MUSC Foundation for Research Development
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
  display_dependencies=
    "#project_funding_status" :
      pending_funding    : ['#pending_funding']
      funded             : ['#funded']
  
  FormFxManager.registerListeners($('.edit-project-view'), display_dependencies)

  $('#project_funding_status').change ->
    $('#project_funding_source').val("")
    $('#project_potential_funding_source').val("")
    $('#project_funding_source').change()
    $('#project_potential_funding_source').change()
    $('#project_indirect_cost_rate').val("")

  $('#project_funding_source, #project_potential_funding_source').change ->
    switch $(this).val()
      when "internal", "college" then $('#project_indirect_cost_rate').val(I18n["indirect_cost_rates"]["internal_and_college"])
      when "industry" then $('#project_indirect_cost_rate').val(I18n["indirect_cost_rates"]["industry"])
      when "foundation", "investigator" then $('#project_indirect_cost_rate').val(I18n["indirect_cost_rates"]["foundation_and_investigator"])
      when "federal" then $('#project_indirect_cost_rate').val(I18n["indirect_cost_rates"]["federal"])

  #This is to disabled the submit after you click once, so you cant fire multiple posts at once.
  $("form").submit ->
    $('a.continue_button').unbind('click');
