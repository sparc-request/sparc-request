class CorrectBadIndirectCostData < ActiveRecord::Migration[5.1]
  def change
    protocols = Protocol.where(indirect_cost_rate: 0.0)
    protocols.each do |protocol|
      protocol.indirect_cost_rate = nil
      protocol.save(validate: false)
    end
  end
end
