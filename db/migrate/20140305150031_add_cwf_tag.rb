class AddCwfTag < ActiveRecord::Migration
  def up
    Tag.create(:name => "clinical work fulfillment")
  end

  def down
    tag = Tag.find_by_name("clinical work fulfillment")
    tag.destroy
  end
end
