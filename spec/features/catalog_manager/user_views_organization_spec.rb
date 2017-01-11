# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

require 'rails_helper'

RSpec.describe 'User views Organization', js: true do
  context 'that is an Institution' do
    before(:each) do
      identity = Identity.create(
          last_name:             'Glenn',
          first_name:            'Julia',
          ldap_uid:              'jug2@musc.edu',
          email:                 'glennj@musc.edu',
          credentials:           'BS,    MRA',
          catalog_overlord:      true,
          password:              'p4ssword',
          password_confirmation: 'p4ssword',
          approved:              true
      )

      institution = create(:institution,
                           name:         'Medical University of South Carolina',
                           order:        1,
                           abbreviation: 'MUSC',
                           is_available: 1)
      CatalogManager.create(
          organization_id:    institution.id,
          identity_id:        identity.id,
          edit_historic_data: true
      )
      login_as(identity)
      visit catalog_manager_root_path
    end

    scenario 'should show status options' do
      click_link "Medical University of South Carolina"
      expect(page).to_not have_content("Status Options")
    end
  end

  context 'that is not an Institution, not process-ssrs' do
    before(:each) do
      identity = Identity.create(
          last_name:             'Glenn',
          first_name:            'Julia',
          ldap_uid:              'jug2@musc.edu',
          email:                 'glennj@musc.edu',
          credentials:           'BS,    MRA',
          catalog_overlord:      true,
          password:              'p4ssword',
          password_confirmation: 'p4ssword',
          approved:              true
      )

      institution = create(:institution,
                           name:         'Medical University of South Carolina',
                           order:        1,
                           abbreviation: 'MUSC',
                           is_available: 1)
      provider = create(:provider,
                        name:                 'South Carolina Clinical and Translational Institute (SCTR)',
                        order:                1,
                        css_class:            'blue-provider',
                        parent_id:            institution.id,
                        abbreviation:         'SCTR1',
                        process_ssrs:         0,
                        is_available:         1)
      create(:service_provider,
             identity_id:     identity.id,
             organization_id: provider.id)
      CatalogManager.create(
          organization_id:    institution.id,
          identity_id:        identity.id,
          edit_historic_data: true
      )
      login_as(identity)
      visit catalog_manager_root_path
    end

    scenario 'should not show status options' do
      click_link "Medical University of South Carolina"
      click_link 'South Carolina Clinical and Translational Institute (SCTR)'
      expect(page).to_not have_content("Status Options")
    end
  end

  context 'that is not an Institution, process-ssrs' do
    before(:each) do
      identity = Identity.create(
          last_name:             'Glenn',
          first_name:            'Julia',
          ldap_uid:              'jug2@musc.edu',
          email:                 'glennj@musc.edu',
          credentials:           'BS,    MRA',
          catalog_overlord:      true,
          password:              'p4ssword',
          password_confirmation: 'p4ssword',
          approved:              true
      )

      institution = create(:institution,
                           name:         'Medical University of South Carolina',
                           order:        1,
                           abbreviation: 'MUSC',
                           is_available: 1)
      provider = create(:provider,
                        name:                 'South Carolina Clinical and Translational Institute (SCTR)',
                        order:                1,
                        css_class:            'blue-provider',
                        parent_id:            institution.id,
                        abbreviation:         'SCTR1',
                        process_ssrs:         1,
                        is_available:         1)
      create(:service_provider,
             identity_id:     identity.id,
             organization_id: provider.id)
      CatalogManager.create(
          organization_id:    institution.id,
          identity_id:        identity.id,
          edit_historic_data: true
      )
      login_as(identity)
      visit catalog_manager_root_path
    end

    scenario 'should not show status options' do
      click_link "Medical University of South Carolina"
      click_link 'South Carolina Clinical and Translational Institute (SCTR)'
      expect(page).to have_content("Status Options")
    end
  end
end