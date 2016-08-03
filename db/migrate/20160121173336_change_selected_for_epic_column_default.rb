# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class ChangeSelectedForEpicColumnDefault < ActiveRecord::Migration
   def change
    change_column :protocols, :selected_for_epic, :boolean, :default => nil
    Rake::Task["add_new_study_type_questions"].invoke
  end
end
