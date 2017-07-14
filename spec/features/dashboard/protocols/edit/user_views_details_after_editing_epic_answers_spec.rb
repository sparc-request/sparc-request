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

require 'rails_helper'

RSpec.describe 'User views details after editing epic answers', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  context 'use epic = true' do
    context 'Study, selected for epic: false, question group 3' do
      scenario 'user views epic answers in view details' do
        protocol = create(:protocol_without_validations,
                          type: 'Study',
                          primary_pi: jug2,
                          funding_status: 'funded',
                          funding_source: 'foundation',
                          selected_for_epic: false,
                          study_type_question_group_id: 3
                        )
        organization    = create(:organization)
        create(:super_user, identity: jug2,
              organization: organization)
        answer_questions(protocol)

        find('.view-protocol-details-button').click
        wait_for_javascript_to_finish

        expect(page).to have_css('h5.col-lg-12', text: 'Study Type Questions:')
        expect(page).to have_css('div.col-lg-2', text: 'Yes')
      end
    end

    context 'Study, selected for epic: true, question group 3' do
      scenario 'user views epic answers in view details' do
        protocol = create(:protocol_without_validations,
                          type: 'Study',
                          primary_pi: jug2,
                          funding_status: 'funded',
                          funding_source: 'foundation',
                          selected_for_epic: true,
                          study_type_question_group_id: 3
                        )
        organization    = create(:organization)
        create(:super_user, identity: jug2,
              organization: organization)
        answer_questions(protocol)

        find('.view-protocol-details-button').click
        wait_for_javascript_to_finish

        expect(page).to have_css('h5.col-lg-12', text: 'Study Type Questions:')
        expect(page).to have_css('div.col-lg-2', text: 'Yes')
      end
    end

    context 'Study, selected for epic: true, question group 2' do
      scenario 'user views epic answers in view details' do
        protocol = create(:protocol_without_validations,
                          type: 'Study',
                          primary_pi: jug2,
                          funding_status: 'funded',
                          funding_source: 'foundation',
                          selected_for_epic: true,
                          study_type_question_group_id: 2
                        )
        organization    = create(:organization)
        create(:super_user, identity: jug2,
              organization: organization)
        answer_questions(protocol)

        find('.view-protocol-details-button').click
        wait_for_javascript_to_finish

        expect(page).to have_css('h5.col-lg-12', text: 'Study Type Questions:')
        expect(page).to have_css('div.col-lg-2', text: 'Yes')
      end
    end
  end

  context 'use epic = false' do
    before :each do
      stub_const('USE_EPIC', false)
    end

    context 'Study, selected for epic: false, question group 3' do
      scenario 'user views epic answers in view details' do
        protocol = create(:protocol_without_validations,
                          type: 'Study',
                          primary_pi: jug2,
                          funding_status: 'funded',
                          funding_source: 'foundation',
                          selected_for_epic: false,
                          study_type_question_group_id: 3
                        )
        organization    = create(:organization)
        create(:super_user, identity: jug2,
              organization: organization)
        answer_questions(protocol, use_epic: false)

        find('.view-protocol-details-button').click
        wait_for_javascript_to_finish

        expect(page).to have_css('h5.col-lg-12', text: 'Study Type Questions:')
        expect(page).to have_css('div.col-lg-2', text: 'Yes')
      end
    end

    context 'Study, selected for epic: true, question group 3' do
      scenario 'user views epic answers in view details' do
        protocol = create(:protocol_without_validations,
                          type: 'Study',
                          primary_pi: jug2,
                          funding_status: 'funded',
                          funding_source: 'foundation',
                          selected_for_epic: true,
                          study_type_question_group_id: 3
                        )
        organization    = create(:organization)
        create(:super_user, identity: jug2,
              organization: organization)
        answer_questions(protocol, use_epic: false)

        find('.view-protocol-details-button').click
        wait_for_javascript_to_finish

        expect(page).to have_css('h5.col-lg-12', text: 'Study Type Questions:')
        expect(page).to have_css('div.col-lg-2', text: 'Yes')
      end
    end

    context 'Study, selected for epic: true, question group 2' do
      scenario 'user views epic answers in view details' do
        protocol = create(:protocol_without_validations,
                          type: 'Study',
                          primary_pi: jug2,
                          funding_status: 'funded',
                          funding_source: 'foundation',
                          selected_for_epic: true,
                          study_type_question_group_id: 2
                        )
        organization    = create(:organization)
        create(:super_user, identity: jug2,
              organization: organization)
        answer_questions(protocol, use_epic: false)

        find('.view-protocol-details-button').click
        wait_for_javascript_to_finish

        expect(page).to have_css('h5.col-lg-12', text: 'Study Type Questions:')
        expect(page).to have_css('div.col-lg-2', text: 'Yes')
      end
    end
  end

  private

  def answer_questions(protocol, use_epic: true)
    visit edit_dashboard_protocol_path(protocol)
    wait_for_javascript_to_finish
    find('.edit-answers', match: :first).click
    wait_for_javascript_to_finish
    if use_epic
      find('#study_selected_for_epic_true_button').click
    end
    wait_for_javascript_to_finish
    if use_epic
      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
    else
      bootstrap_select('#study_type_answer_certificate_of_conf_no_epic_answer',
                       'Yes'
                      )
    end
    wait_for_javascript_to_finish
    click_button 'Save'
    wait_for_javascript_to_finish
  end
end

