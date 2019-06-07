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

class AddTableauEmbedSettings < ActiveRecord::Migration[5.1]
  def up
    unless Setting.find_by_key('use_tableau')
      Setting.create(
        key: 'use_tableau',
        value: true,
        data_type: 'boolean',
        friendly_name: 'Use Tableau',
        description: 'Determines whether the application will integrate with Tableau.'
      )
    end

    unless Setting.find_by_key('homepage_tableau_url')
      Setting.new(
        key: 'homepage_tableau_url',
        value: "https://anyl-tableau-v.mdc.musc.edu/javascripts/api/viz_v1.js",
        data_type: 'url',
        friendly_name: 'Homepage Tableau Url',
        description: 'The URL of the Tableau server used to embed a dashboard on the SPARCRequest homepage.',
        parent_key: 'use_tableau',
        parent_value: 'true'
      ).save(validate: false)
    end

    unless Setting.find_by_key('homepage_tableau_dashboard')
      Setting.new(
        key: 'homepage_tableau_dashboard',
        value: "InstitutionalDashboard/RadialTreeDashboard",
        data_type: 'string',
        friendly_name: 'Homepage Tableau Dashboard',
        description: 'The name of the dashboard to be embedded on the SPARCRequest homepage.',
        parent_key: 'use_tableau',
        parent_value: 'true'
      ).save(validate: false)
    end
  end

  def down
    Setting.find_by_key('use_tableau').try(:destroy)
    Setting.find_by_key('homepage_tableau_url').try(:destroy)
    Setting.find_by_key('homepage_tableau_dashboard').try(:destroy)
  end
end
