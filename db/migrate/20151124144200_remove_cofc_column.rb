# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class RemoveCofcColumn < ActiveRecord::Migration
  def change
    Rake::Task["migrate_cofc"].invoke
    remove_column :protocols, :has_cofc
  end
end
