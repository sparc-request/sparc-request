class FixOldSsrStatusValues < ActiveRecord::Migration
  def up
    old_statuses = ["in process", "ctrc review", "ctrc approved", "on hold", "awaiting pi approval"]
    ssrs = SubServiceRequest.all.select {|x| old_statuses.include?(x.status)}
    ssrs.each do |ssr|
      ssr.update_attributes({:status => ssr.status.gsub(' ', '_')})
    end
  end

  def down
  end
end
