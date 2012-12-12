class Provider < Organization
  belongs_to :institution, :class_name => "Organization", :foreign_key => "parent_id"
  has_many :programs, :dependent => :destroy, :foreign_key => "parent_id"
end
