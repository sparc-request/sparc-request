class UpdateOrgTreeForExistingSsr < ActiveRecord::Migration
  def up
    SubServiceRequest.all.each do |ssr|
      puts "Updating org tree for #{ssr.id}"
      ssr.update_org_tree
    end
  end

  def down
  end
end
