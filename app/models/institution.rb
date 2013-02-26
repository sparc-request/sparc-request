class Institution < Organization
  has_many :providers, :dependent => :destroy, :foreign_key => "parent_id"

  def populate_for_edit
    self.setup_available_statuses
  end

  def setup_available_statuses
    position = 1
    obj_names = AvailableStatus::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      available_status = available_statuses.detect{|obj| obj.status == obj_name}
      available_status = available_statuses.build(:status => obj_name, :new => true) unless available_status
      available_status.position = position
      position += 1
    end

    available_statuses.sort!{|a, b| a.position <=> b.position}
  end
end
