# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

RSpec.describe 'User wants to archive/unarchive a protocol', js: true do
  let_there_be_lane
  fake_login_for_each_test

  context 'archive protocol' do
    before :each do
      @project  = create(:unarchived_project_without_validations, primary_pi: jug2)
                  create(:service_request_without_validations, protocol: @project)

      visit dashboard_protocol_path(@project)
      wait_for_javascript_to_finish
    end

    it 'should render archive confirm prompt' do
      click_link I18n.t('protocols.summary.archive')
      wait_for_javascript_to_finish

      within(page.document.find(:css, '.swal2-actions')) do
        find(:css, '.swal2-confirm').click
        wait_for_javascript_to_finish

        expect(@project.reload.archived).to eq(true)
        expect(page.document).to have_content(I18n.t('protocols.summary.unarchive'))
      end
    end

    #it 'should archive the protocol' do
      #click_link I18n.t('protocols.summary.archive')
      #wait_for_javascript_to_finish

      #expect(@project.reload.archived).to eq(true)
      #expect(page).to have_content(I18n.t('protocols.summary.unarchive'))
    #end
  end

  context 'unarchive protocol' do
    before :each do
      @project  = create(:archived_project_without_validations, primary_pi: jug2)
                  create(:service_request_without_validations, protocol: @project)

      visit dashboard_protocol_path(@project)
      wait_for_javascript_to_finish
    end

    it 'should render unarchive confirm prompt' do
      click_link I18n.t('protocols.summary.unarchive')
      wait_for_javascript_to_finish

      within(page.document.find(:css, '.swal2-actions')) do
        find(:css, '.swal2-confirm').click
        wait_for_javascript_to_finish

        expect(@project.reload.archived).to eq(false)
        expect(page.document).to have_content(I18n.t('protocols.summary.archive'))
      end
    end

    #it 'should unarchive the protocol' do
      #click_link I18n.t('protocols.summary.unarchive')
      #wait_for_javascript_to_finish

      #expect(@project.reload.archived).to eq(false)
      #expect(page).to have_content(I18n.t('protocols.summary.archive'))
    #end
  end
end
