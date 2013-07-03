class MakeFirstPiPrimary < ActiveRecord::Migration
  def up
    protocols = Protocol.all

    ActiveRecord::Base.transaction do
      protocols.each do |protocol|
        protocol.project_roles.each do |pr|
          if pr.role == 'pi'
            pr.update_attributes(:role => 'primary-pi')
            break
          end
        end
      end
    end
  end

  def down
  end
end
