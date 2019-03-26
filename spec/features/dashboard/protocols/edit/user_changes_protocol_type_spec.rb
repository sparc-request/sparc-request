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

require 'rails_helper'

RSpec.describe 'User changes protocol type', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  context 'User is an admin' do
    before :each do
      @protocol       = create(:protocol_without_validations,
                                type: "Project",
                                primary_pi: jug2,
                                funding_status: "funded",
                                funding_source: "foundation",
                                selected_for_epic: nil)
      organization    = create(:organization)
      service_request = create(:service_request_without_validations,
                               protocol: @protocol)
                        create(:sub_service_request_without_validations,
                               organization: organization,
                               service_request: service_request,
                               status: 'draft')
                        create(:super_user, identity: jug2,
                               organization: organization)
      allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish
    end

    context 'use epic = true' do
      stub_config("use_epic", true)

      context "changes the protocol type" do
        before :each do
          bootstrap_select '#protocol_type', 'Study'
          find('#protocol-type-button').click

          accept_confirm
          wait_for_javascript_to_finish
        end

        context "does not fill out 'Publish Study in Epic'" do
          it 'should throw an error for selected for epic' do
            click_button 'Save'
            expect(page).to have_content("Selected for epic is not included in the list")
          end
        end

        context 'selects "Yes" for "Publish Study in Epic"' do
          context "does not fill out study type questions and saves" do
            it 'should throw an error for study type answers' do
              find('#study_selected_for_epic_true_button').click
              wait_for_javascript_to_finish
              click_button 'Save'
              expect(page).to have_content("Study type answers must be selected")
            end
          end

          context 'fills out the first study type question and saves' do
            it 'should save successfully' do
              find('#study_selected_for_epic_true_button').click
              wait_for_javascript_to_finish

              bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
              wait_for_javascript_to_finish

              click_button 'Save'
              expect(page).to have_content("Study Updated!")
            end
          end
        end

        context 'selects "No" for "Publish Study in Epic"' do
          context "does not fill out study type questions and saves" do
            it 'should save successfully' do
              fill_in 'protocol_sponsor_name', with: 'Hogwarts'
              find('#study_selected_for_epic_false_button').click
              wait_for_javascript_to_finish
              click_button 'Save'
              expect(page).to have_content("Study Updated!")
            end
          end
        end
      end
    end

    context 'use epic = false' do
      stub_config("use_epic", false)
      context "changes the protocol type" do
        before :each do
          bootstrap_select '#protocol_type', 'Study'
          find('#protocol-type-button').click

          accept_confirm
          wait_for_javascript_to_finish
        end

        it 'should not display "Publish Study in Epic"' do
          expect(page).not_to have_css('label.col-lg-4', text: 'Publish Study in Epic:')
        end

        context 'does not fill out study type questions and saves' do
          it 'should save successfully' do
            wait_for_javascript_to_finish
            click_button 'Save'
            expect(page).to have_content("Study Updated!")
          end
        end

        context 'fills out the first study type question and saves' do
          it 'should save successfully' do
            bootstrap_select'#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
            wait_for_javascript_to_finish

            click_button 'Save'
            expect(page).to have_content("Study Updated!")
          end
        end
      end
    end
  end
end
