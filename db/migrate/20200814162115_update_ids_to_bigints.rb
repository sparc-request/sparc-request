class UpdateIdsToBigints < ActiveRecord::Migration[5.2]
  def change
    Rake::Task['migrate_ids_to_bigint'].invoke
  end
end
