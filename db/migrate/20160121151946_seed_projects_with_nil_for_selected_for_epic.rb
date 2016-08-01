# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class SeedProjectsWithNilForSelectedForEpic < ActiveRecord::Migration
  def up
  	projects = Protocol.where(type: 'Project')
  	projects.each do |project|
  		project.update_attribute(:selected_for_epic, nil)
  	end
  end

  def down
  end
end
