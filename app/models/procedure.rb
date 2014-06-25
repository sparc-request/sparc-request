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
  attr_accessible :unit_factor_cost
  attr_accessible :toasts_generated

  after_create :fix_toasts_if_uncompleted

  def fix_toasts_if_uncompleted
    unless self.appointment.completed?
      self.update_attributes(toasts_generated: true)
    end
  end

  def required?
    self.visit.to_be_performed?
  end

  def display_service_name
    self.service ? self.try(:service).try(:name) : self.try(:line_item).try(:service).try(:name)
  end

  def direct_service
    self.service ? self.service : self.line_item.service
  end

  def core
    self.service ? self.try(:service).try(:organization) : self.try(:line_item).try(:service).try(:organization)
  end

  # This method is primarily for setting the initial r_quantity values on the visit calendar in 
  # clinical work fulfillment.
  def default_r_quantity
    service_quantity = self.r_quantity
    unless self.appointment.visit_group_id.nil?
      if self.service
        service_quantity ||= 0
      else
        service_quantity ||= self.visit.research_billing_qty
      end
    end

    service_quantity
  end

  # This method is primarily for setting the initial t_quantity values on the visit calendar in 
  # clinical work fulfillment.
  def default_t_quantity
    service_quantity = self.t_quantity
    unless self.appointment.visit_group_id.nil?
      if self.service
        service_quantity ||= 0
      else
        service_quantity ||= self.visit.insurance_billing_qty
      end
    end

    service_quantity
  end

  def cost
    if self.service
      funding_source = self.appointment.calendar.subject.arm.protocol.funding_source_based_on_status #OHGOD
      organization = service.organization
		  if self.appointment.completed_at?
		  	pricing_map = service.effective_pricing_map_for_date(appointment.completed_at)
		  	pricing_setup = organization.effective_pricing_setup_for_date(appointment.completed_at)
		  else
		  	pricing_map = service.effective_pricing_map_for_date
		  	pricing_setup = organization.effective_pricing_setup_for_date
		  end
				
      rate_type = pricing_setup.rate_type(funding_source)
      if pricing_map.unit_factor > 1
        if self.unit_factor_cost
          return Service.cents_to_dollars(self.unit_factor_cost / self.default_r_quantity)
        else
          return Service.cents_to_dollars(pricing_map.applicable_rate(rate_type, pricing_setup.applied_percentage(rate_type)))
        end
      else
        return Service.cents_to_dollars(pricing_map.applicable_rate(rate_type, pricing_setup.applied_percentage(rate_type)))
      end
    else
      self.line_item.pricing_scheme = 'effective'
      if self.default_r_quantity == 0
        return (self.line_item.per_unit_cost(1) / 100).to_f
      else
        if self.line_item.service.displayed_pricing_map.unit_factor > 1
          subtotals = self.visit.line_items_visit.per_subject_subtotals
          return Service.cents_to_dollars(subtotals[self.visit_id.to_s] / self.default_r_quantity)
        else
          return (self.line_item.per_unit_cost(self.default_r_quantity, self.appointment.completed_at) / 100).to_f
        end
      end
    end
  end

  # Totals up a given row on the visit schedule
  def total
    if self.completed? and self.r_quantity
      return self.r_quantity * self.cost
    else
      return 0.00
    end
  end

  def should_be_displayed
    procedure = Procedure.includes(:appointment, :visit).find(self.id)
    if procedure.service
      return true
    elsif procedure.appointment.visit_group_id.nil?
      return true if self.completed
    else
      if (procedure.visit.research_billing_qty && procedure.visit.research_billing_qty > 0) or (procedure.visit.insurance_billing_qty && procedure.visit.insurance_billing_qty > 0)
        return true
      else
        return false
      end
    end
  end

  ### audit reporting methods ###
    
  def audit_label audit
    subject = appointment.calendar.subject
    subject_label = subject.respond_to?(:audit_label) ? subject.audit_label(audit) : "Subject #{subject.id}"
    return "Procedure (#{display_service_name}) for #{subject_label} on #{appointment.visit_group.name}"
  end
 
  def audit_excluded_fields
    {'create' => ['toasts_generated', 'visit_id', 'service_id', 'appointment_id', 'line_item_id', 'unit_factor_cost'], 'update' => ['toasts_generated', 'appointment_id', 'visit_id', 'line_item_id']}
  end

  ### end audit reporting methods ###
end
