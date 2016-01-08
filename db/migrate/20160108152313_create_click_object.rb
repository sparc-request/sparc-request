class CreateClickObject < ActiveRecord::Migration
  def change
    ClickCounter.create
  end
end
