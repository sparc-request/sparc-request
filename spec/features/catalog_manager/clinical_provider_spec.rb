
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

require 'spec_helper'

RSpec.feature 'clinical_providers' do
  before :each do
    default_catalog_manager_setup
    Tag.create(name: "clinical work fulfillment")
    click_link('Office of Biomedical Informatics')
    wait_for_javascript_to_finish
  end

  context "adding fulfillment tag" do
    before :each do
      @program = Organization.where(abbreviation: "Informatics").first
      wait_for_javascript_to_finish
      find('#program_tag_list_clinical_work_fulfillment').click
      within '#cwf_fieldset' do
        find('.legend').click
        wait_for_javascript_to_finish
      end
      sleep 3
      fill_in "new_cp", with: "Julia"
      wait_for_javascript_to_finish
      page.find('a', text: "Julia Glenn", visible: true).click()
      wait_for_javascript_to_finish
    end

    it "should add a clinical provider from an organization", js: true do
      expect(page).to have_content("Julia Glenn (glennj@musc.edu)")
    end

    it "should delete a clinical provider from an organization", js: true do
      within "#cp_info" do
        find("img.cp_delete").click
      end
      within "#cp_info" do
        expect(page).not_to have_text("Julia Glenn")
      end
    end
  end
end
