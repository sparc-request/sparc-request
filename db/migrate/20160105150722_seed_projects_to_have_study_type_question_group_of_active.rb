class SeedProjectsToHaveStudyTypeQuestionGroupOfActive < ActiveRecord::Migration
  def up
  	projects = Protocol.where(type: 'Project')
  	projects.each do |project|
  		project.update_attribute(:study_type_question_group_id, StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
  	end
  end

  def down
  end
end
