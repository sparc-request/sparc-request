class AddDjSlackwebhookUrl < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    SettingsPopulator.new().populate
  end
end
