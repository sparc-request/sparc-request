class AddDefaultsToArmsColumns < ActiveRecord::Migration
  def up
    change_column :arms, :visit_count, :integer, :default => 1
    change_column :arms, :subject_count, :integer, :default => 1
  end

  def down
    change_column :arms, :subject_count, :integer, :default => nil
    change_column :arms, :visit_count, :integer, :default => nil
  end
end
