class FixVisitCalendar < ActiveRecord::Migration
  def up
    Visit.all.each do |visit|
      case visit.billing
      when 'R'
        visit.update_attribute(:research_billing_qty, visit.quantity)
      when 'T'
        visit.update_attribute(:insurance_billing_qty, visit.quantity)
      when '%'
        visit.update_attribute(:effort_billing_qty, visit.quantity)
      end
    end
  end

  def down
  end
end
