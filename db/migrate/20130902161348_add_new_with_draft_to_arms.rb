class AddNewWithDraftToArms < ActiveRecord::Migration
  def up
    add_column :arms, :new_with_draft, :boolean, :default => false

    Arm.all.each do |arm|
      arm.update_attribute(:new_with_draft, false)
    end
  end

  def down
    remove_column :arms, :new_with_draft
  end
end
