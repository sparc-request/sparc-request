class PopulateDefaultSettingsData < ActiveRecord::Migration[5.0]

  def change
    DefaultSettingsPopulator.new().populate
  end
end
