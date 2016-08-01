# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
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
