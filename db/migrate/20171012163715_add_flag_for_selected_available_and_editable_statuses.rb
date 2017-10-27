class AddFlagForSelectedAvailableAndEditableStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :available_statuses, :selected, :boolean, default: false
    add_column :editable_statuses, :selected, :boolean, default: false

    AvailableStatus.update_all(selected: true)

    ActiveRecord::Base.transaction do
      avs = []
      eds = []
      Organization.includes(:available_statuses, :editable_statuses).each do |org|
        org.editable_statuses.select{|es| org.available_statuses.selected.pluck(:status).include?(es.status)}.update_all(selected: true)
        avs += (AvailableStatus::TYPES -  org.available_statuses.pluck(:status)).map{|status| AvailableStatus.new( organization: org, status: status )}
        eds += (AvailableStatus::TYPES - org.editable_statuses.pluck(:status)).map{|status| EditableStatus.new( organization: org, status: status )}
      end
      AvailableStatus.import avs
      EditableStatus.import eds
    end
  end
end
