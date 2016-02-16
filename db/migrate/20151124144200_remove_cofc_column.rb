class RemoveCofcColumn < ActiveRecord::Migration
  def change
    Rake::Task["migrate_cofc"].invoke
    remove_column :protocols, :has_cofc
  end
end
