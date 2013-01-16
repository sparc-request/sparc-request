class FixProjectFundingStatusAndSource < ActiveRecord::Migration
  def up
    Project.all.each do |p|
      p.update_attribute(:funding_status, 'pending_funding')
      fs = p.funding_source
      pfs = p.potential_funding_source

      if !fs.nil? && !pfs.nil?
        p.update_attribute(:funding_source, nil)
      elsif pfs.nil?
        p.update_attribute(:potential_funding_source, fs)
        p.update_attribute(:funding_source, nil)
      end
    end
  end

  def down
  end
end
