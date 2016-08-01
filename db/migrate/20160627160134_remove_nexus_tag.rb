# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class RemoveNexusTag < ActiveRecord::Migration

  class Tag < ActiveRecord::Base
    audited
    attr_accessible :name
    has_many :taggings, dependent: :destroy, class_name: '::ActsAsTaggableOn::Tagging'
  end

  def change
  	Tag.where(name: 'ctrc_clinical_services').destroy_all
  end
end
