class Core < Organization
  belongs_to :program, :class_name => "Organization", :foreign_key => "parent_id"
  has_many :services, :dependent => :destroy, :foreign_key => "organization_id"
end
