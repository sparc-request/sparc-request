class MoveArmsToProtocols < ActiveRecord::Migration

  class Protocol < ActiveRecord::Base
    has_many :arms
  end

  class ServiceRequest < ActiveRecord::Base
    has_many :arms
  end

  class Arm < ActiveRecord::Base
    attr_accessible :protocol_id
    attr_accessible :service_request_id
    belongs_to :service_request
    belongs_to :protocol
  end

  def up
    add_column :arms, :protocol_id, :integer
    Arm.reset_column_information
    Arm.all.each do |arm|
      arm.update_attribute(:protocol_id, arm.service_request.protocol_id)
    end
    remove_column :arms, :service_request_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
