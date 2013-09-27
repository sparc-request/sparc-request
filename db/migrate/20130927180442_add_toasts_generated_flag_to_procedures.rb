class AddToastsGeneratedFlagToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :toasts_generated, :boolean, :default => false
  end
end
