class AddNewSettings < ActiveRecord::Migration[5.2]
  def change
    SettingsPopulator.new().populate
  end
end
