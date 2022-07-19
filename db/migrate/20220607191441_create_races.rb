class CreateRaces < ActiveRecord::Migration[5.2]
  def change
    create_table :races do |t|
      t.references  :identity
      t.string      :name,      null: false
      t.string      :other_text

      t.timestamps
    end

    Identity.where.not(race: [nil, ""]).each do |id|
      Race.create(
        identity_id: id.id,
        name: id.race
      )
    end

    Race.where(name: 'middle_eastern').update_all(name: 'other', other_text: 'Middle Eastern')
    PermissibleValue.where(category: 'race', key: 'middle_eastern').destroy_all

    remove_column :identities, :race

  end
end
