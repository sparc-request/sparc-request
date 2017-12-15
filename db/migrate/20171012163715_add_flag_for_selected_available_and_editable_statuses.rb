class AddFlagForSelectedAvailableAndEditableStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :available_statuses, :selected, :boolean, default: false
    add_column :editable_statuses, :selected, :boolean, default: false

    AvailableStatus.update_all(selected: true)

    ActiveRecord::Base.transaction do
      avs = []
      eds = []
      selected_eds = []
      Organization.includes(:available_statuses, :editable_statuses).each do |org|
        selected_eds += org.editable_statuses.where(status: org.available_statuses.selected.pluck(:status))
        avs += (AvailableStatus.types-  org.available_statuses.pluck(:status)).map{|status| AvailableStatus.new( organization: org, status: status )}
        eds += (EditableStatus.types - org.editable_statuses.pluck(:status)).map{|status| EditableStatus.new( organization: org, status: status )}
      end
      EditableStatus.where(id: selected_eds).update_all(selected: true)
      AvailableStatus.import avs
      EditableStatus.import eds
    end
  end
end
