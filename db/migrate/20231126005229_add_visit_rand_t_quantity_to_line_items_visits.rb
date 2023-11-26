class AddVisitRandTQuantityToLineItemsVisits < ActiveRecord::Migration[5.2]
  def up
    add_column :line_items_visits, :visit_i_quantity, :integer, default: 0
    add_column :line_items_visits, :visit_e_quantity, :integer, default: 0

    bar = ProgressBar.new(LineItemsVisit.count)

    LineItemsVisit.includes(:visits).find_each do |liv|
      (bar.increment! && next) if liv.visits.empty?
      i_quantity = liv.visits.sum(:insurance_billing_qty)
      e_quantity = liv.visits.sum(:effort_billing_qty)
      liv.visit_i_quantity = i_quantity
      liv.visit_e_quantity = e_quantity
      liv.save!(validate: false)
      bar.increment!
    end
  end

  def down
    remove_column :line_items_visits, :visit_i_quantity
    remove_column :line_items_visits, :visit_e_quantity
  end
end
