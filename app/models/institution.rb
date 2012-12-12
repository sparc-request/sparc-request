class Institution < Organization
  has_many :providers, :dependent => :destroy, :foreign_key => "parent_id"
end
