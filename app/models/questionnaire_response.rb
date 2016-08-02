class QuestionnaireResponse < ActiveRecord::Base
  belongs_to :submission
  belongs_to :item
end
