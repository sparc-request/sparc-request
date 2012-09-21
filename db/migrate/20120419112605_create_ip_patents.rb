class CreateIpPatents < ActiveRecord::Migration
  def change
    create_table :ip_patents do |t|
      t.integer :protocol_id
      t.string :patent_number
      t.text :inventors

      t.timestamps
    end

    add_index :ip_patents, :protocol_id
  end
end
