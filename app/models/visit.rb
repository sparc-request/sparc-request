class Visit < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :line_item

  acts_as_list :scope => :line_item
  include BulkCreateableList

  attr_accessible :line_item_id
  attr_accessible :quantity
  attr_accessible :billing
  attr_accessible :research_billing_qty #qty billed to the study/project
  attr_accessible :insurance_billing_qty #qty billed to the patients insurance or third party
  attr_accessible :effort_billing_qty #qty billing to % effort
  attr_accessible :position

  validates :research_billing_qty, :numericality => {:only_integer => true}
  validates :insurance_billing_qty, :numericality => {:only_integer => true}
  validates :effort_billing_qty, :numericality => {:only_integer => true}

  # Visits are ordered by their monotonically increasing id.  Be careful
  # when inserting new visits!
  # TODO: This is no longer true, since we're using acts_as_list.
  # Should we remove default_scope?
  # default_scope :order => 'id ASC'

  def cost(per_unit_cost = self.line_item.per_unit_cost(self.line_item.quantity_total))
    li = self.line_item
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

end

class Visit::ObisEntitySerializer
  def as_json(visit, options = nil)
    h = {
      'billing' => visit.billing,
      'quantity' => visit.quantity,
    }

    return h
  end

  def update_from_json(visit, h, options = nil)
    visit.update_attributes!(
        billing:  h['billing'],
        quantity: h['quantity'])
  end
end

class Visit
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

