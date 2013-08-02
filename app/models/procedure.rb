class Procedure < ActiveRecord::Base
  audited

  belongs_to :appointment
  belongs_to :visit
  belongs_to :line_item
  belongs_to :service
  attr_accessible :appointment_id
  attr_accessible :visit_id
  attr_accessible :line_item_id
  attr_accessible :completed
  attr_accessible :service_id
  attr_accessible :r_quantity
  attr_accessible :t_quantity

  def required?
    self.visit.to_be_performed?
  end

  def display_service_name
    self.service ? self.try(:service).try(:name) : self.try(:line_item).try(:service).try(:name)
  end

  def core
    self.service ? self.try(:service).try(:organization) : self.try(:line_item).try(:service).try(:organization)
  end

  # This method is primarily for setting the initial r_quantity values on the visit calendar in 
  # clinical work fulfillment.
  def default_r_quantity
    service_quantity = self.r_quantity
    if self.service
      service_quantity ||= 0
    else
      service_quantity ||= self.visit.research_billing_qty
    end
    service_quantity
  end

  # This method is primarily for setting the initial t_quantity values on the visit calendar in 
  # clinical work fulfillment.
  def default_t_quantity
    service_quantity = self.t_quantity
    if self.service
      service_quantity ||= 0
    else
      service_quantity ||= self.visit.insurance_billing_qty
    end
    service_quantity
  end

  def cost
    if self.service
      funding_source = self.appointment.calendar.subject.arm.service_request.protocol.funding_source_based_on_status #OHGOD
      organization = service.organization
      pricing_map = service.current_pricing_map
      pricing_setup = organization.current_pricing_setup
      rate_type = pricing_setup.rate_type(funding_source)
      return (pricing_map.full_rate * (pricing_setup.applied_percentage(rate_type) / 100)).to_f
    else
      return (self.line_item.per_unit_cost(self.visit.research_billing_qty) / 100).to_f
    end
  end

  # Totals up a given row on the visit schedule
  def total
    self.default_r_quantity * self.cost
  end

  def should_be_displayed
    if self.service
      return true
    else
      if (self.visit.research_billing_qty && self.visit.research_billing_qty > 0) or (self.visit.insurance_billing_qty && self.visit.insurance_billing_qty > 0)
        return true
      else
        return false
      end
    end
  end
end
