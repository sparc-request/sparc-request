class VisitGroup < ActiveRecord::Base
  belongs_to :arm
  has_many :visits, :dependent => :destroy
  attr_accessible :name
  attr_accessible :position
  acts_as_list :scope => :arm

  after_create :set_default_name

  def set_default_name
    if name.nil? || name == ""
      self.update_attributes(:name => "Visit #{self.position}")
    end
  end

end
