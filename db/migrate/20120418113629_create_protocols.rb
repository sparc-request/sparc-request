class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :type
      t.string :obisid
      t.integer :next_ssr_id
      t.string :short_title
      t.text :title
      t.string :sponsor_name
      t.text :brief_description
      t.decimal :indirect_cost_rate, :precision => 5, :scale => 2
      t.string :study_phase
      t.string :udak_project_number
      t.string :funding_rfa
      t.string :funding_status
      t.string :potential_funding_source
      t.datetime :potential_funding_start_date
      t.string :funding_source
      t.datetime :funding_start_date
      t.string :federal_grant_serial_number
      t.string :federal_grant_title
      t.string :federal_grant_code_id
      t.string :federal_non_phs_sponsor
      t.string :federal_phs_sponsor

      t.timestamps
    end

    add_index :protocols, :obisid
  end
end
