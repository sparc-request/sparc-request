desc "preserve historic study types"
task :preserve_historic_study_types => :environment do 
	study_answers = []
	studies = Study.all

	studies.each do |study|
		if study.study_type_answers.present?
      StudyTypeQuestion.find_each do |stq|
        study_answers << stq.study_type_answers.find_by_protocol_id(study.id).answer 
      end
    end

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

    historic_study_type_answers.each do |historic_study_type, historic_answer|
    	if historic_answer == study_answers #then we have the historic study type
    		STUDY_TYPE_ANSWERS.each do |new_study_type, new_answer|
    			if historic_study_type == new_study_type
    				#we need to take the new_answers and populate them into the study_answers
    				StudyTypeQuestion.find_each.with_index do |study_type_question, index| 
           		study_type_question.study_type_answers[index].update_attributes(answer: new_answer)
      # STUDY_TYPE_ANSWERS.each do |new_study_type, new_answers|
      #   if historic_study_type == new_study_type
      #     new_answers.each_with_index do |answer, index|
      #     	StudyTypeQuestion.find_each do |study_type_question| 
      #     		study_type_question.study_type_answers[index].update_attributes(answer: answer)
          	# StudyTypeQuestion.first.study_type_answers[1].update_attributes(answer: 0)
            # study.study_type_answers[index].update_attributes(answer: answer)
          	end
          end
        end
      end
    end
	end
end