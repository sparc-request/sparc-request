# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class StudyTypeAnswer < ActiveRecord::Base
  belongs_to :study_type_question
  attr_accessible :answer, :protocol_id, :study_type_question_id
end
