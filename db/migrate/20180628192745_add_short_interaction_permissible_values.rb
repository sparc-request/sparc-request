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

class AddShortInteractionPermissibleValues < ActiveRecord::Migration[5.2]
  def change
    ## add 3 interaction_type pvs: email, in-person, telephone ##
    unless PermissibleValue.where(category: 'interaction_type').exists?
      PermissibleValue.create(category: 'interaction_type', key: 'email', value: 'Email', sort_order: 1)
      PermissibleValue.create(category: 'interaction_type', key: 'in_person', value: 'In-Person', sort_order: 2)
      PermissibleValue.create(category: 'interaction_type', key: 'phone', value: 'Telephone', sort_order: 3)
      PermissibleValue.where(category: 'interaction_type').update_all(is_available: true)
    end

    ## add interaction_subject pvs - add or remove items from the following list as you wish ##
    unless PermissibleValue.where(category: 'interaction_subject').exists?
      PermissibleValue.create(category: 'interaction_subject', key: 'bmi_apps', value: 'Bioinformatics Software Choice, Training and Applications')
      PermissibleValue.create(category: 'interaction_subject', key: 'bmi__study_design', value: 'Bioinformatics Study Design')
      PermissibleValue.create(category: 'interaction_subject', key: 'biostatistical_question', value: 'Biostatistical Question')
      PermissibleValue.create(category: 'interaction_subject', key: 'career_development', value: 'Career Development')
      PermissibleValue.create(category: 'interaction_subject', key: 'funding_opportunities', value: 'Funding Opportunities')
      PermissibleValue.create(category: 'interaction_subject', key: 'general_question', value: 'General Question')
      PermissibleValue.create(category: 'interaction_subject', key: 'redcap', value: 'REDCap')
      PermissibleValue.create(category: 'interaction_subject', key: 'regulatory_question', value: 'Regulatory Question')
      PermissibleValue.where(category: 'interaction_subject').update_all(is_available: true)
    end
  end
end
