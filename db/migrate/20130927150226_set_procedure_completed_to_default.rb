class SetProcedureCompletedToDefault < ActiveRecord::Migration
  def up
    change_column :procedures, :completed, :boolean, :default => false
    Procedure.update_all({:completed => false}, {:completed => nil})
  end

  def down
  end
end
