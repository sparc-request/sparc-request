class CreateEditableStatuses < ActiveRecord::Migration[5.0]
  def up
    create_table :editable_statuses do |t|
      t.references  :organization,  index: true, foreign_key: true
      t.string      :status,        null: false

      t.timestamps                  null: false
    end

    if defined?(EDITABLE_STATUSES)
      EDITABLE_STATUSES.each do |org_id, statuses|
        if organization = Organization.find_by_id(org_id)
          (statuses << 'first_draft').each do |status|
            organization.editable_statuses.create(status: status)
          end
        end
      end

      Organization.where.not(id: EDITABLE_STATUSES.keys).each do |org|
        (AVAILABLE_STATUSES.keys << 'first_draft').each do |status|
          org.editable_statuses.create(status: status)
        end
      end
    else
      Organization.all.each do |org|
        (AVAILABLE_STATUSES.keys << 'first_draft').each do |status|
          org.editable_statuses.create(status: status)
        end
      end
    end
  end

  def down
    drop_table :editable_statuses
  end
end
