class RemoveEpicTagFromOrgs < ActiveRecord::Migration
  def change
    Organization.all.each do |org|
      if org.tag_list.include?("epic")
        org.tag_list.remove("epic")
        org.save
      end
    end
  end
end
