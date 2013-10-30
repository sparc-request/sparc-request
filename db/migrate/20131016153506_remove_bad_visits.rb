class RemoveBadVisits < ActiveRecord::Migration
  def up
    visits = Visit.all.select {|x| x.line_items_visit_id == nil && x.visit_group_id == nil}
    visits.each do |visit|
      visit.procedures.each do |procedure|
        puts 'DESTROYING PROCEDURE' + procedure.inspect
        procedure.destroy
      end
      puts 'DESTROYING VISIT' + visit.inspect
      visit.destroy
    end
  end

  def down
  end
end
