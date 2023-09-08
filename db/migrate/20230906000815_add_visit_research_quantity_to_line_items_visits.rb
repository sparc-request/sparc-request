class AddVisitResearchQuantityToLineItemsVisits < ActiveRecord::Migration[5.2]
  def up
    add_column :line_items_visits, :visit_r_quantity, :integer

    bar = ProgressBar.new(LineItemsVisit.count)

    LineItemsVisit.includes(:visits).find_each do |liv|
      (bar.increment! && next) if liv.visits.empty?
      r_quantity = liv.visits.sum(:research_billing_qty)
      liv.visit_r_quantity = r_quantity
      liv.save!(validate: false)
      bar.increment!
    end
  end

  def down
    remove_column :line_items_visits, :visit_r_quantity
  end
end
