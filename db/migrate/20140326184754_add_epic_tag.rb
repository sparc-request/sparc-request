class AddEpicTag < ActiveRecord::Migration
  def up
    Tag.create(:name => "epic")
  end

  def down
    tag = Tag.find_by_name("epic")
    tag.destroy
  end
end
