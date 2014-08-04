# Copyright © 2011 MUSC Foundation for Research Development
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

describe 'edit an institution', :js => true do


  before :each do
    default_catalog_manager_setup
    Tag.create(:name => "ctrc")
    click_link('Medical University of South Carolina')
  end


  context 'successfully update an existing institution' do
    it "should successfully edit and save the institution" do
      # General Information fields
      fill_in 'institution_abbreviation', :with => 'GreatestInstitution'
      fill_in 'institution_description', :with => 'Description'
      fill_in 'institution_ack_language', :with => 'Language'
      fill_in 'institution_order', :with => '1'
      select('blue', :from => 'institution_css_class')
      uncheck('institution_is_available')
      
      first("#save_button").click
      page.should have_content( 'Medical University of South Carolina saved successfully' )
    end


    context "adding and removing tags" do
      before :each do
        @institution = Organization.where(abbreviation: "MUSC").first
        wait_for_javascript_to_finish
      end

      it "should list the tags" do
        page.should have_css("#institution_tag_list_ctrc")
      end

      it "should be able to check a tag box" do
        find('#institution_tag_list_ctrc').click
        first("#save_button").click
        page.should have_content( 'Medical University of South Carolina saved successfully' )
        find('#institution_tag_list_ctrc').should be_checked
        @institution.tag_list.should eq(['ctrc'])
      end
    end


    context "viewing user rights section" do
      it "should show user rights section" do
        find('#user_rights').click
        sleep 3
        find('#su_info').should be_visible
      end
    end
  end
end