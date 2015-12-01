desc "Study type report"
task :study_type_report => :environment do 
  CSV.open('tmp/study_type_answers.csv', 'wb') do |csv|
    csv << ['Study ID', 'Study Type']
    Study.all.each do |study|
      answers = []
      if study.study_type_answers.present?
        StudyTypeQuestion.find_each do |stq|
          answers << stq.study_type_answers.find_by_protocol_id(study.id).answer 
        end
      end

      study_type = nil
      STUDY_TYPE_ANSWERS.each do |k, v|
        if v == answers
          study_type = k
          break
        end
      end
      csv << [study.id, study_type]
    end
  end
end