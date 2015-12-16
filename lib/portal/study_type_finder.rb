module Portal

  class StudyTypeFinder

  	def initialize(study)
  		@study = study
  		@active_answers = Array.new
  		@inactive_answers = Array.new
  		@study_type = nil
  	end

  	def study_type
  		if @study.study_type_answers.present?
  			if @study.active?
	  			StudyTypeQuestion.active.find_each do |stq|
	          @active_answers << stq.study_type_answers.find_by_protocol_id(@study.id).answer 
	        end
	        STUDY_TYPE_ANSWERS_VERSION_2.each do |k, v|
	          if v == @active_answers
	            @study_type = k
	            break
	          end
	        end
	        @study_type
	      elsif !@study.active?
	        StudyTypeQuestion.inactive.find_each do |stq|
	          @inactive_answers << stq.study_type_answers.find_by_protocol_id(@study.id).answer 
	        end
	        STUDY_TYPE_ANSWERS.each do |k, v|
	          if v == @inactive_answers
	            @study_type = k
	            break
	          end
	        end
	        @study_type
	      end
	  	end
	  end

  end
end