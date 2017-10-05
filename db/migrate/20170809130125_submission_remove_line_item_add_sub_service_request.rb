class SubmissionRemoveLineItemAddSubServiceRequest < ActiveRecord::Migration[5.1]
  def change
    add_reference :submissions, :sub_service_request, index: true, foreign_key: true, type: :integer
    Submission.find_each do |sub|
      sub.update(sub_service_request: LineItem.find(sub.line_item_id).sub_service_request)
    end
    remove_reference :submissions, :line_item, index: true, foreign_key: true
  end
end
