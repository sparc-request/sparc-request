class RenameMuhaTag < ActiveRecord::Migration
  def up
    tag = Tag.find_by_name('muha')
    tag.name = 'required forms'
    tag.save
  end

  def down
    tag = Tag.find_by_name('required forms')
    tag.name = 'muha'
    tag.save
  end
end
