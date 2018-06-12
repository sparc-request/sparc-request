# Copyright © 2011-2018 MUSC Foundation for Research Development
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

require 'rails_helper'

RSpec.describe "protocols/view_details.html.haml", type: :view do

  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  describe "view details of a project" do
    before(:each) do
      protocol = create(
      :unarchived_project_without_validations,
      primary_pi: user,
      research_master_id: 1
      )

      render "protocols/view_details.html.haml", protocol: protocol
    end

    it 'renders the partials for a project' do
      expect(response).to render_template("protocols/_view_details.html.haml")
      expect(response).to render_template(partial: "protocols/view_details/_project_fields")
    end
  end

  describe "view details of a study" do
    stub_config("use_epic", true)
    
    before(:each) do
      protocol = create(
        :study_without_validations_with_questions,
        primary_pi: user,
        research_master_id: 1,
        selected_for_epic: true
      )
      render "protocols/view_details.html.haml", protocol: protocol
    end

    it 'renders all of the study-specific partials' do
      expect(response).to render_template("protocols/_view_details.html.haml")
      expect(response).to render_template(partial: "protocols/view_details/_study_fields")
      expect(response).to render_template(partial: "protocols/view_details/_study_information")
      expect(response).to render_template(partial: "protocols/view_details/_financial_information")
      expect(response).to render_template(partial: "protocols/view_details/_research_involving")
      expect(response).to render_template(partial: "protocols/view_details/_study_type")
      expect(response).to render_template(partial: "protocols/view_details/_impact_areas")
      expect(response).to render_template(partial: "protocols/view_details/_affiliations")
      expect(response).to render_template(partial: "protocols/view_details/_study_type_note")
      expect(response).to render_template(partial: "protocols/view_details/_epic_questions_answers")
    end
  end
end
