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

RSpec.describe 'User views details after editing epic answers', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  context 'use epic = true' do
    stub_config("use_epic", true)
    
    context 'Study, selected for epic: true, question group 3' do
      context 'user views epic answers in view details' do
        before :each do
          @protocol = create(:protocol_without_validations,
                            type: 'Study',
                            primary_pi: jug2,
                            funding_status: 'funded',
                            funding_source: 'foundation',
                            selected_for_epic: true,
                            study_type_question_group_id: 3
                          )
          organization    = create(:organization)
          create(:super_user, identity: jug2,
                organization: organization,
                access_empty_protocols: true)
          allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        end

        ### PUBLISH STUDY IN EPIC IS TRUE ###
        context 'edits study so that the answer to "Publish Study in Epic" is "Yes"' do
          context 'only answers the first question' do

            it 'should display "Publish Study in Epic" as "Yes"' do 
              answer_first_question(@protocol)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              expect(page).to have_selector('div.col-lg-8', text: 'Yes')
            end

            it 'should display "Yes" as the answer for the first Question' do
              answer_first_question(@protocol)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
            end

            it 'should display the correct note' do
              answer_first_question(@protocol)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('#study_type_note', text: 'Note: De-identified Research Participant')
            end
          end

          context 'answers all questions' do

            it 'should display "Publish Study in Epic" as "Yes"' do 
              answer_all_questions(@protocol)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              expect(page).to have_selector('div.col-lg-8', text: 'Yes')
            end

            it 'should display "No" for all answers' do
              answer_all_questions(@protocol)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              expect(page).to have_selector('div.col-lg-2', text: 'No', count: 5)
            end

            it 'should display the correct note' do
              answer_all_questions(@protocol)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('#study_type_note', text: 'Note: Full Epic Functionality: no notification, no pink header, no MyChart access.')
            end
          end
        end
      end
    end

    context 'Study, selected for epic: false, question group 3' do
      context 'user views epic answers in view details' do
        before :each do
          @protocol = create(:protocol_without_validations,
                            type: 'Study',
                            primary_pi: jug2,
                            funding_status: 'funded',
                            funding_source: 'foundation',
                            selected_for_epic: false,
                            study_type_question_group_id: 3
                          )
          organization    = create(:organization)
          create(:super_user, identity: jug2,
                organization: organization,
                access_empty_protocols: true)
          allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        end

        ### PUBLISH STUDY IN EPIC IS FALSE ###
        context 'edits study so that the answer to "Publish Study in Epic" is "No"' do
          context 'only answers the first question' do

            it 'should display "Publish Study in Epic" as "No"' do 
              answer_first_question(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              expect(page).to have_selector('div.col-lg-8', text: 'No')
            end

            it 'should display "No" as the answer for the first Question' do
              answer_first_question(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
            end

            it 'should display the correct note' do
              answer_first_question(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).not_to have_selector('#study_type_note')
            end
          end

          context 'answers all questions' do

            it 'should display "Publish Study in Epic" as "No"' do 
              answer_all_questions(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              expect(page).to have_selector('div.col-lg-8', text: 'No')
            end

            it 'should display "No" for all answers' do
              answer_all_questions(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              expect(page).to have_selector('div.col-lg-2', text: 'No', count: 2)
            end

            it 'should not display a note' do
              answer_all_questions(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).not_to have_selector('#study_type_note')
            end
          end
        end
      end
    end

    context 'Study, selected for epic: true, question group 2' do
      context 'user views epic answers in view details' do
        before :each do
          @protocol = create(:protocol_without_validations,
                            type: 'Study',
                            primary_pi: jug2,
                            funding_status: 'funded',
                            funding_source: 'foundation',
                            selected_for_epic: true,
                            study_type_question_group_id: 2
                          )
          organization    = create(:organization)
          create(:super_user, identity: jug2,
                organization: organization,
                access_empty_protocols: true)
          setup_data_for_version_2_study(@protocol)
          allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        end

        ### STUDY TYPE QUESTION GROUP 2 ###
        context 'study that belongs to study type question group 2' do
          context 'does not edit and views study details' do
            before :each do
              visit dashboard_protocol_path(@protocol)
              wait_for_javascript_to_finish

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish
            end

            it 'should display correct selected for epic' do
              expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              expect(page).to have_selector('div.col-lg-8', text: 'Yes')
            end

            it 'should display question group 2 study type questions and answers' do
              expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              expect(page).to have_content(@stq_certificate_of_conf_version_2.question)
              expect(page).to have_selector('div.col-lg-2', text: 'Yes')
              expect(page).not_to have_content(@stq_higher_level_of_privacy_version_2.question)
              expect(page).not_to have_content(@stq_access_study_info_version_2.question)
              expect(page).not_to have_content(@stq_epic_inbasket_version_2.question)
              expect(page).not_to have_content(@stq_research_active_version_2.question)
              expect(page).not_to have_content(@stq_restrict_sending_version_2.question)
            end

            it 'should not display a note' do
              expect(page).to have_selector('#study_type_note', text: "")
            end
          end
        end

        context 'edits study so that the answer to "Publish Study in Epic" is "No"' do
          context 'only answers the first question' do

            it 'should display "Publish Study in Epic" as "No"' do 
              answer_first_question(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              expect(page).to have_selector('div.col-lg-8', text: 'No')
            end

            it 'should display "No" as the answer for the first Question' do
              answer_first_question(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
            end

            it 'should display the correct note' do
              answer_first_question(@protocol, true, false)

              find('.view-protocol-details-button').click
              wait_for_javascript_to_finish

              expect(page).not_to have_selector('#study_type_note')
            end
          end

          context 'edits study so that the answer to "Publish Study in Epic" is "Yes"' do
            context 'only answers the first question' do

              it 'should display "Publish Study in Epic" as "Yes"' do 
                answer_first_question(@protocol)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
                expect(page).to have_selector('div.col-lg-8', text: 'Yes')
              end

              it 'should display "Yes" as the answer for the first Question' do
                answer_first_question(@protocol)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
                expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
              end

              it 'should display the correct note' do
                answer_first_question(@protocol)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).to have_selector('#study_type_note', text: 'Note: De-identified Research Participant')
              end
            end
          end
        end
      end
    end
  end

  context 'use epic = false' do
    stub_config('use_epic', false)
    ### SELECTED FOR EPIC IS FALSE IS IRRELEVANT BECAUSE USE_EPIC = FALSE ###
    context 'Study, selected for epic: false, question group 3' do
      context 'user views epic answers in view details' do
        before :each do
          @protocol = create(:protocol_without_validations,
                            type: 'Study',
                            primary_pi: jug2,
                            funding_status: 'funded',
                            funding_source: 'foundation',
                            selected_for_epic: false,
                            study_type_question_group_id: 3
                          )
          organization    = create(:organization)
          create(:super_user, identity: jug2,
                organization: organization,
                access_empty_protocols: true)
          allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        end

        context 'only answers the first question' do

          it 'should not display "Publish Study in Epic" label' do 
            answer_first_question(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
          end

          it 'should display "No" as the answer for the first Question' do
            answer_first_question(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
            expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
          end

          it 'should not display a note' do
            answer_first_question(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('#study_type_note')
          end
        end

        context 'answers all questions' do

          it 'should not display "Publish Study in Epic" label' do 
            answer_all_questions(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
          end

          it 'should display "No" for all answers' do
            answer_all_questions(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
            expect(page).to have_selector('div.col-lg-2', text: 'No', count: 2)
          end

          it 'should not display a note' do
            answer_all_questions(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('#study_type_note')
          end
        end
      end
    end
    ### SELECTED FOR EPIC IS TRUE IS IRRELEVANT BECAUSE USE_EPIC = FALSE ###
    context 'Study, selected for epic: true, question group 3' do
      context 'user views epic answers in view details' do
        before :each do
          @protocol = create(:protocol_without_validations,
                            type: 'Study',
                            primary_pi: jug2,
                            funding_status: 'funded',
                            funding_source: 'foundation',
                            selected_for_epic: true,
                            study_type_question_group_id: 3
                          )
          organization    = create(:organization)
          create(:super_user, identity: jug2,
                organization: organization,
                access_empty_protocols: true)
          allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
        end

        context 'only answers the first question' do

          it 'should not display "Publish Study in Epic" label' do 
            answer_first_question(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
          end

          it 'should display "No" as the answer for the first Question' do
            answer_first_question(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
            expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
          end

          it 'should not display a note' do
            answer_first_question(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('#study_type_note')
          end
        end

        context 'answers all questions' do

          it 'should not display "Publish Study in Epic" label' do 
            answer_all_questions(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
          end

          it 'should display "No" for all answers' do
            answer_all_questions(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
            expect(page).to have_selector('div.col-lg-2', text: 'No', count: 2)
          end

          it 'should not display a note' do
            answer_all_questions(@protocol, false, false)

            find('.view-protocol-details-button').click
            wait_for_javascript_to_finish

            expect(page).not_to have_selector('#study_type_note')
          end
        end
      end
    end

    context 'Study, selected for epic: true, question group 2' do
      context 'user views epic answers in view details' do
        context 'and does not see "Publish Study in Epic" or "Study Type Questions:"' do
          before :each do
            @protocol = create(:protocol_without_validations,
                              type: 'Study',
                              primary_pi: jug2,
                              funding_status: 'funded',
                              funding_source: 'foundation',
                              selected_for_epic: true,
                              study_type_question_group_id: 2
                            )
            organization    = create(:organization)
            create(:super_user, identity: jug2,
                  organization: organization,
                  access_empty_protocols: true)
            allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
            setup_data_for_version_2_study(@protocol)
            visit dashboard_protocol_path(@protocol)
            wait_for_javascript_to_finish
          end

          context 'study that belongs to study type question group 2' do
            context 'does not edit and views study details' do
              before :each do
                visit dashboard_protocol_path(@protocol)
                wait_for_javascript_to_finish

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish
              end

              it 'should not display selected for epic' do
                expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              end

              it 'should display question group 2 study type questions and answers' do
                expect(page).not_to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
              end

              it 'should not display a note' do
                expect(page).not_to have_selector('#study_type_note')
              end
            end

            context 'only answers the first question' do

              it 'should not display "Publish Study in Epic" label' do 
                answer_first_question(@protocol, false, false)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              end

              it 'should display "No" as the answer for the first Question' do
                answer_first_question(@protocol, false, false)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
                expect(page).to have_selector('div.col-lg-2', text: 'Yes', count: 1)
              end

              it 'should not display a note' do
                answer_first_question(@protocol, false, false)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).not_to have_selector('#study_type_note')
              end
            end

            context 'answers all questions' do

              it 'should not display "Publish Study in Epic" label' do 
                answer_all_questions(@protocol, false, false)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).not_to have_selector('label.col-lg-4', text: 'Publish Study in Epic:')
              end

              it 'should display "No" for all answers' do
                answer_all_questions(@protocol, false, false)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).to have_selector('h5.col-lg-12', text: 'Study Type Questions:')
                expect(page).to have_selector('div.col-lg-2', text: 'No', count: 2)
              end

              it 'should not display a note' do
                answer_all_questions(@protocol, false, false)

                find('.view-protocol-details-button').click
                wait_for_javascript_to_finish

                expect(page).not_to have_selector('#study_type_note')
              end
            end
          end
        end
      end
    end
  end

  private

  def answer_first_question(protocol, use_epic=true, selected_for_epic=true)
    visit edit_dashboard_protocol_path(protocol)
    wait_for_javascript_to_finish
    find('.edit-answers', match: :first).click
    wait_for_javascript_to_finish

    if use_epic
      if selected_for_epic
        find('#study_selected_for_epic_true_button').click
        wait_for_javascript_to_finish
        bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
      else
        find('#study_selected_for_epic_false_button').click
        wait_for_javascript_to_finish
        bootstrap_select'#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
      end
    else
      bootstrap_select'#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
    end

    wait_for_javascript_to_finish
    click_button 'Save'
    wait_for_page(dashboard_protocol_path(protocol))
  end

  def answer_all_questions(protocol, use_epic=true, selected_for_epic=true)
    visit edit_dashboard_protocol_path(protocol)
    wait_for_javascript_to_finish
    find('.edit-answers', match: :first).click
    wait_for_javascript_to_finish

    if use_epic
      if selected_for_epic
        find('#study_selected_for_epic_true_button').click
      else
        find('#study_selected_for_epic_false_button').click
      end
      wait_for_javascript_to_finish
    end
    
    if selected_for_epic
      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_higher_level_of_privacy_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_epic_inbasket_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_research_active_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_restrict_sending_answer', 'No'
      wait_for_javascript_to_finish  
    else
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'No'
      wait_for_javascript_to_finish
    end
    wait_for_javascript_to_finish
    click_button 'Save'
    wait_for_page(dashboard_protocol_path(protocol))
  end

  def setup_data_for_version_2_study(protocol)
    ### STQ GROUP ###
    @study_type_question_group_version_2 = StudyTypeQuestionGroup.create(active: false, version: 2)
    ### STQ'S ###
    @stq_certificate_of_conf_version_2 = StudyTypeQuestion.create("order"=>1, "question"=>"1. Does your study have a Certificate of Confidentiality?", "friendly_id"=>"certificate_of_conf", "study_type_question_group_id" => @study_type_question_group_version_2.id) 
    @stq_higher_level_of_privacy_version_2 = StudyTypeQuestion.create("order"=>2, "question"=>"2. Does your study require a higher level of privacy for the participants?", "friendly_id"=>"higher_level_of_privacy", "study_type_question_group_id" => @study_type_question_group_version_2.id) 
    @stq_access_study_info_version_2 = StudyTypeQuestion.create("order"=>3, "question"=>"2b. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?", "friendly_id"=>"access_study_info", "study_type_question_group_id" => @study_type_question_group_version_2.id) 
    @stq_epic_inbasket_version_2 = StudyTypeQuestion.create("order"=>4, "question"=>"3. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?", "friendly_id"=>"epic_inbasket", "study_type_question_group_id" => @study_type_question_group_version_2.id) 
    @stq_research_active_version_2 = StudyTypeQuestion.create("order"=>5, "question"=>"4. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?", "friendly_id"=>"research_active", "study_type_question_group_id" => @study_type_question_group_version_2.id) 
    @stq_restrict_sending_version_2 = StudyTypeQuestion.create("order"=>6, "question"=>"5. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?", "friendly_id"=>"restrict_sending", "study_type_question_group_id" => @study_type_question_group_version_2.id) 

    ### ST ANSWERS ###
    StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: @stq_certificate_of_conf_version_2.id, answer: 1)
    StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: @stq_higher_level_of_privacy_version_2.id, answer: nil)
    StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: @stq_access_study_info_version_2.id, answer: nil)
    StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: @stq_epic_inbasket_version_2.id, answer: nil)
    StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: @stq_research_active_version_2.id, answer: nil)
    StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: @stq_restrict_sending_version_2.id, answer: nil)

    protocol.update_attribute(:selected_for_epic, true)
    protocol.update_attribute(:study_type_question_group_id, @study_type_question_group_version_2.id)
    active_study_type_group = StudyTypeQuestionGroup.create(active: true, version: 3)
  end
end

