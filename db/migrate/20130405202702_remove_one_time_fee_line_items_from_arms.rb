class RemoveOneTimeFeeLineItemsFromArms < ActiveRecord::Migration
  class ServiceRequest < ActiveRecord::Base
    has_many :arms
    has_many :line_items
  end
  class VisitGrouping < ActiveRecord::Base
    belongs_to :line_item
    belongs_to :arm
    has_many :visits
    attr_accessible :arm_id, :subject_count
  end
  class Arm < ActiveRecord::Base
    attr_accessible :name
    attr_accessible :visit_count
    attr_accessible :subject_count
    has_many :visit_groupings
  end

  def up
    service_requests = ServiceRequest.all

    ActiveRecord::Base.transaction do
      service_requests.each do |service_request|
        service_request.arms.each do |arm|
          # Remove visit groupings that are for one time fee line items
          one_time_fee_visit_groupings = arm.visit_groupings.select do |vg|
            vg.line_item.service.is_one_time_fee?
          end

          if one_time_fee_visit_groupings.count > 0 then
            say "Destroying #{one_time_fee_visit_groupings.count} visit groupings because they are for one time fee line items"
            one_time_fee_visit_groupings.each do |vg|
              vg.destroy
            end
          end

          # Remove the arm if it no longer has any visit groupings (i.e.
          # the service request only has one time fee line items)
          if arm.visit_groupings.empty? then
            say "Destroying arm #{arm.id} because it has has no visit groupings"
            arm.destroy
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
