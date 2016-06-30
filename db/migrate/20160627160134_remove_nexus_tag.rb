class Tag < ActiveRecord::Base
  audited
  attr_accessible :name
  has_many :taggings, dependent: :destroy, class_name: '::ActsAsTaggableOn::Tagging'
end

class RemoveNexusTag < ActiveRecord::Migration
  def change
  	Tag.where(name: 'ctrc_clinical_services').destroy_all
  end
end
