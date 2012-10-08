class CreateIpPatentsInfo < ActiveRecord::Migration
  def change
    create_table :ip_patents_info do |t|
      t.integer :protocol_id
      t.string :patent_number
      t.text :inventors

      t.timestamps
    end

    add_index :ip_patents_info, :protocol_id
  end
end
