desc "preserve historic study types"
task :preserve_historic_study_types => :environment do 
	answers = []
	studies = Study.all
	studies.each do |study|
		if study.study_type_answers.present?
      StudyTypeQuestion.find_each do |stq|
        answers << stq.study_type_answers.find_by_protocol_id(study.id).answer 
      end
    end
    study_type = nil
    historic_study_type_answers = { '1' => [true, true, nil, nil, nil, nil],
							                     '2' => [true, false, true, nil, nil, nil],
							                     '3' => [true, false, false, false, true, true],
							                     '4' => [true, false, false, false, false, true],
							                     '5' => [true, false, false, false, true, false],
							                     '6' => [true, false, false, false, false, false],
							                     '7' => [true, false, false, true, true, true],
							                     '8' => [true, false, false, true, false, true],
							                     '9' => [true, false, false, true, true, false],
							                     '10' => [true, false, false, true, false, false],
							                     '11' => [false, nil, nil, false, true, true],
							                     '12' => [false, nil, nil, false, false, true],
							                     '13' => [false, nil, nil, false, true, false],
							                     '14' => [false, nil, nil, false, false, false],
							                     '15' => [false, nil, nil, true, true, true],
							                     '16' => [false, nil, nil, true, false, true],
							                     '17' => [false, nil, nil, true, true, false],
							                     '0' => [false, nil, nil, true, false, false] }

    historic_study_type_answers.each do |k, v|
      if v == answers
        study_type = k
        

        
        break
      end
    end
	end
end