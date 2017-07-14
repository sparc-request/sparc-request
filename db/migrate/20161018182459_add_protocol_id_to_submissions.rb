class AddProtocolIdToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_reference :submissions, :protocol, index: true, foreign_key: true, after: :questionnaire_id
  end
end
