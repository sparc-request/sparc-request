class CreateAdditionalFundingSources < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_funding_sources do |t|
      t.string :funding_source
      t.string :funding_source_other
      t.string :sponsor_name
      t.text :comments
      t.string :federal_grant_code
      t.string :federal_grant_serial_number
      t.string :federal_grant_title
      t.string :phs_sponsor
      t.string :non_phs_sponsor
      t.references :protocol, foreign_key: true

      t.timestamps
    end
  end
end
