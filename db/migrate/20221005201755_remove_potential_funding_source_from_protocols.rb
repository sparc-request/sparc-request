class RemovePotentialFundingSourceFromProtocols < ActiveRecord::Migration[5.2]
  def change
    protocols = Protocol.where.not(potential_funding_source: [nil, ""])
    bar = ProgressBar.new(protocols.count)
    protocols.each do |p|
      if !p.funding_source?
        p.funding_source = p.potential_funding_source
        unless p.funding_start_date?
          p.funding_start_date = p.potential_funding_start_date
        end
      elsif p.funding_source? && !p.funding_start_date?
        p.funding_start_date = p.potential_funding_start_date
      end

      p.save(validate: false)
      bar.increment!
    end

    remove_column :protocols, :potential_funding_source
    remove_column :protocols, :potential_funding_start_date
  end
end
