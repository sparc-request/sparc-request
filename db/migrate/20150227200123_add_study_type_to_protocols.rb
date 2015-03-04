class AddStudyTypeToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :study_type, :string
  end
end
