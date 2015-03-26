namespace :data do
  desc "Create study type questions based on constants file"
  task :create_study_type_questions => :environment do

    friendly_ids = ['higher_level_of_privacy', 'certificate_of_conf', 'access_study_info', 'epic_inbasket', 'research_active', 'restrict_sending']

    STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
      StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index])
    end
  end
end
