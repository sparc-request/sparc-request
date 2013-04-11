class Calendar < ActiveRecord::Base
  belongs_to :subject

  def populate(visits)
  end
  
end
