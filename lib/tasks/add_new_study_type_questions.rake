desc "add new study type questions"
task :add_new_study_type_questions => :environment do
	friendly_ids = ['certificate_of_conf', 'higher_level_of_privacy', 'access_study_info', 'epic_inbasket', 'research_active', 'restrict_sending']

	study_type_questions_version_2 = ["1. Does your study have a Certificate of Confidentiality?", 
	                                 "2. Does your study require a higher level of privacy for the participants?",
	                                 "2b. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?",
	                                 "3. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?",
	                                 "4. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?",
	                                 "5. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?"]
  study_type_questions_version_2.each_with_index do |stq, index|
    StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index], study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)
  end
end
