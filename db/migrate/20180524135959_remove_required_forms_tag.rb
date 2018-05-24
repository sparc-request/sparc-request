class RemoveRequiredFormsTag < ActiveRecord::Migration[5.2]
  class Tagging < ApplicationRecord
  end


  def change
    tag = Tag.find_by_name('required forms')
    taggings = Tagging.where(tag_id: tag.id)

    tag.destroy
    taggings.destroy_all
  end
end
