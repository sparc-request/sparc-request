class MoveDataToArms < ActiveRecord::Migration

  class ServiceRequest < ActiveRecord::Base
    has_many :arms
    has_many :line_items
  end

  class LineItem < ActiveRecord::Base
    has_many :visits
    has_many :visit_groupings
  end

  class Visit < ActiveRecord::Base
  end

  class Arm < ActiveRecord::Base
    attr_accessible :name
    attr_accessible :visit_count
    attr_accessible :subject_count
  end

  def up
    LineItem.reset_column_information

    add_column :visits, :visit_grouping_id, :integer
    Visit.reset_column_information

    add_column :arms, :subject_count, :integer
    Arm.reset_column_information

    service_requests = ServiceRequest.all

    service_requests.each do |service_request|
      arm = service_request.arms.create! :name => 'ARM 1', :visit_count => service_request.visit_count, :subject_count => service_request.subject_count

      # Create a new visit grouping for each line item
      # (this really should have been only done for per-patient
      # per-visit line items; see the
      # remove_one_time_fee_line_items_from_arms migration for the fix)
      service_request.line_items.each do |line_item|
        visit_grouping = line_item.visit_groupings.create! :arm_id => arm.id, :subject_count => line_item.subject_count

        line_item.visits.each do |visit|
          visit.update_attribute :visit_grouping_id, visit_grouping.id
        end
      end
    end

    remove_column :service_requests, :visit_count
    remove_column :line_items, :subject_count
    remove_column :visits, :line_item_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
