class RemovePotentialFundingSourceOtherFromProtocols < ActiveRecord::Migration[5.2]
  def change
    
    Protocol.where.not(potential_funding_source_other: [nil, ""]).each do |p|
      p.update_attribute(:funding_source_other, p.potential_funding_source_other)
    end
    
    remove_column :protocols, :potential_funding_source_other
  end
end
