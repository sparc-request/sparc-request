class ComponentsFromModelToServiceAttr < ActiveRecord::Migration
  
  class ServiceLevelComponent < ActiveRecord::Base
    attr_accessible :service_id
    attr_accessible :component
    attr_accessible :position
  end

  def up
    add_column :services, :components, :text
    remove_column :services, :service_level_components_count

    Service.all.each do |service|
      components_list = ""
      ServiceLevelComponent.where(service_id: service.id).each{ |slc| components_list += slc.component + "," }
      service.update_column(:components, components_list)
    end

    drop_table :service_level_components
  end

  def down
    create_table :service_level_components do |t|
      t.references :service
      t.string :component
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :service_level_components, :service_id

    Service.all.each do |service|
      if service.components
        components_list = service.components.split(',')
        (0...components_list.length).each do |i|
          ServiceLevelComponent.create(service_id: service.id, component: components_list[i], position: i)
        end
      end
    end

    remove_column :services, :components
    add_column :services, :service_level_components_count, :integer
  end
end
