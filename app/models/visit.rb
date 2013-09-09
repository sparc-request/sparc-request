class Visit < ActiveRecord::Base
  audited

  belongs_to :visit_grouping

  acts_as_list :scope => :visit_grouping
  include BulkCreateableList

  attr_accessible :visit_grouping_id
  attr_accessible :quantity
  attr_accessible :billing
  attr_accessible :research_billing_qty #qty billed to the study/project
  attr_accessible :insurance_billing_qty #qty billed to the patients insurance or third party
  attr_accessible :effort_billing_qty #qty billing to % effort
  attr_accessible :position
  attr_accessible :name

  validates :research_billing_qty, :numericality => {:only_integer => true}
  validates :insurance_billing_qty, :numericality => {:only_integer => true}
  validates :effort_billing_qty, :numericality => {:only_integer => true}

  # Visits are ordered by their monotonically increasing id.  Be careful
  # when inserting new visits!
  # TODO: This is no longer true, since we're using acts_as_list.
  # Should we remove default_scope?
  # default_scope :order => 'id ASC'

  after_create :set_default_name

  def cost(per_unit_cost = self.visit_grouping.per_unit_cost(self.visit_grouping.quantity_total))
    li = self.visit_grouping.line_item
    if li.applicable_rate == "N/A"
      return "N/A"
    elsif self.research_billing_qty >= 1
      return self.research_billing_qty * per_unit_cost
    else
      return nil
    end
  end

  def quantity_total
    self.research_billing_qty + self.insurance_billing_qty + self.effort_billing_qty
  end

  def set_default_name
    if name.nil? || name == ""
      self.update_attributes(:name => "Visit #{self.position}")
    end
  end 

end
