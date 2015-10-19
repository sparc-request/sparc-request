# This migration comes from acts_as_taggable_on_engine (originally 2)
class AddMissingUniqueIndices < ActiveRecord::Migration
  def self.up
    add_index :tags, :name, unique: true

    remove_index :taggings, :tag_id if index_exists?(:taggings, :tag_id)
    # in case the previous line does nothing, also try removing it by "index name"
    remove_index(:taggings, name: "index_taggings_on_tag_id") if index_exists?(:taggings, :tag_id, name: "index_taggings_on_tag_id")
    
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'taggings_idx'
  end

  def self.down
    remove_index :tags, :name

    remove_index :taggings, name: 'taggings_idx'
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
