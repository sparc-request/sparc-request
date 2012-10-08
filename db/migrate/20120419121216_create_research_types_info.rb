class CreateResearchTypesInfo < ActiveRecord::Migration
  def change
    create_table :research_types_info do |t|
      t.integer :protocol_id
      t.boolean :human_subjects
      t.boolean :vertebrate_animals
      t.boolean :investigational_products
      t.boolean :ip_patents

      t.timestamps
    end

    add_index :research_types_info, :protocol_id
  end
end
