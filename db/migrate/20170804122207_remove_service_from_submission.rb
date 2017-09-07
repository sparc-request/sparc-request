class RemoveServiceFromSubmission < ActiveRecord::Migration[5.1]
  def change
    remove_reference :submissions, :service, index: true, foreign_key: true
  end
end
