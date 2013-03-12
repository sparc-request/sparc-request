class Arm < ActiveRecord::Base
  belongs_to :service_request

  has_many :visit_groupings, :dependent => :destroy
  has_many :line_items, :through => :visit_groupings

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count

  def per_patient_per_visit_line_items
    visit_groupings.each.map do |vg|
      vg.line_item.service.is_one_time_fee? ? nil : vg.line_item
    end.compact
  end

  def per_patient_per_visit_visit_groupings
    visit_groupings.each.map do |vg|
      vg.line_item.service.is_one_time_fee? ? nil : vg
    end.compact
  end

  def maximum_direct_costs_per_patient visit_groupings=self.visit_groupings
    total = 0.0
    per_patient_per_visit_visit_groupings.each do |vg|
      total += vg.direct_costs_for_visit_based_service_single_subject
    end

    total
  end
end
