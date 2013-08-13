class Visit < ActiveRecord::Base
  audited

  belongs_to :line_items_visit
  has_many :procedures
  has_many :appointments, :through => :procedures
  belongs_to :visit_group

  attr_accessible :line_items_visit_id
  attr_accessible :visit_group_id
  attr_accessible :quantity
  attr_accessible :billing
  attr_accessible :research_billing_qty  # (R) qty billed to the study/project
  attr_accessible :insurance_billing_qty # (T) qty billed to the patients insurance or third party
  attr_accessible :effort_billing_qty    # (%) qty billing to % effort

  validates :research_billing_qty, :numericality => {:only_integer => true}
  validates :insurance_billing_qty, :numericality => {:only_integer => true}
  validates :effort_billing_qty, :numericality => {:only_integer => true}

  # Find a Visit for the given "line items visit" and visit group.  Does
  # not create the visit if it does not exist.
  # TODO: perhaps it _should_ create the visit?
  def self.for(line_items_visit, visit_group)
    return Visit.find_by_line_items_visit_id_and_visit_group_id(
        line_items_visit.id,
        visit_group.id)
  end

  def cost(per_unit_cost = self.line_items_visit.per_unit_cost(self.line_items_visit.quantity_total))
    li = self.line_items_visit.line_item
    if li.applicable_rate == "N/A"
      return "N/A"
    elsif self.research_billing_qty >= 1
      return self.research_billing_qty * per_unit_cost
    else
      return nil
    end
  end

  def quantity_total
    return research_billing_qty.to_i + insurance_billing_qty.to_i + effort_billing_qty.to_i
  end

  def position
    ##get position from visit_group
    return self.visit_group.position
  end

  def to_be_performed?
    self.research_billing_qty > 0
  end
end
