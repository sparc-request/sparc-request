require 'rails_helper'
RSpec.describe 'editing a study', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test

  build_service_request()
  build_arms()
  build_one_time_fee_services()
  build_per_patient_per_visit_services()
  build_study_type_question_groups()
  build_study_type_questions()

  let!(:answer1)  { StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: stq_higher_level_of_privacy.id, answer: 1)}
  let!(:answer2)  { StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: stq_certificate_of_conf.id, answer: 0)}
  let!(:answer3)  { StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: stq_access_study_info.id, answer: 0)}
  let!(:answer4)  { StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: stq_epic_inbasket.id, answer: 0)}
  let!(:answer5)  { StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: stq_research_active.id, answer: 1)}
  let!(:answer6)  { StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: stq_restrict_sending.id, answer: 1)}

  let!(:study) {

    protocol = build(:study)
    protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 50.0, start_date: Time.now, end_date: Time.now + 2.month, selected_for_epic: false, study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)
    protocol.save validate: false
    identity = Identity.find_by_ldap_uid('jug2')
    create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity.id,
        project_rights:  "approve",
        role:            "primary-pi")
    identity2 = Identity.find_by_ldap_uid('jpl6@musc.edu')
    create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity2.id,
        project_rights:  "approve",
        role:            "business-grants-manager")
    service_request.update_attribute(:protocol_id, protocol.id)
    protocol.reload
    protocol
  }

  before :each do
    add_visits
    study.update_attributes(potential_funding_start_date: (Time.now + 1.day))
    study.update_attributes(funding_start_date: nil)
    study.human_subjects_info.update_attributes(irb_expiration_date: nil)
    study.update_attributes(selected_for_epic: true)
    study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.inactive.pluck(:id).first)
    visit portal_admin_sub_service_request_path sub_service_request.id
    click_on('Project/Study Information')
    wait_for_javascript_to_finish
  end

  context 'epic box' do
    it 'should not throw an error when saved' do
      click_button 'Save'
      expect(page).to_not have_content("Study type questions must be selected")
    end
  end
end