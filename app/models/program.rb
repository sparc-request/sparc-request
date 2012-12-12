class Program < Organization
  include Entity

  belongs_to :provider, :class_name => "Organization", :foreign_key => "parent_id"
  has_many :cores, :dependent => :destroy, :foreign_key => "parent_id"
  has_many :services, :dependent => :destroy, :foreign_key => "organization_id"
end
