class QuestionnaireResponse < ActiveRecord::Base
  belongs_to :submission
  belongs_to :item
  validates :content, presence: true, if: :required?

  def required?
    required == true
  end
end
