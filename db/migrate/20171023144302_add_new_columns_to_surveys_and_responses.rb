class AddNewColumnsToSurveysAndResponses < ActiveRecord::Migration[5.1]
  def up
    responses = Response.all.to_a

    # Add type to Surveys
    add_column :surveys, :type, :string
    Survey.update_all(type: 'SystemSurvey')

    # Add surveyable_id and surveyable_type to Surveys
    add_column :surveys, :surveyable_id, :integer
    add_column :surveys, :surveyable_type, :string

    add_index :surveys, [:surveyable_id, :surveyable_type], name: :index_surveys_on_surveyable_id_and_surveyable_type, using: :btree

    # Allow display_order to be null
    change_column :surveys, :display_order, :integer, null: true

    # Add respondable_id and respondable_type to Responses
    add_column :responses, :respondable_id, :integer
    add_column :responses, :respondable_type, :string

    add_index :responses, [:respondable_id, :respondable_type], name: :index_responses_on_respondable_id_and_respondable_type, using: :btree

    # Remove sub_service_request_id from Responses
    remove_foreign_key :responses, column: :sub_service_request_id
    remove_column :responses, :sub_service_request_id

    # Rename associated_surveys association
    rename_column :associated_surveys, :surveyable_id, :associable_id
    rename_column :associated_surveys, :surveyable_type, :associable_type

    Survey.reset_column_information
    Response.reset_column_information
    AssociatedSurvey.reset_column_information

    # Replace sub_service_request_id with respondable_id and respondable_type='SubServiceRequest'
    responses.select{ |r| r.sub_service_request_id != nil }.each do |r|
      reloaded_response = Response.find(r.id)
      reloaded_response.update_attributes(respondable_id: r.sub_service_request_id, respondable_type: 'SubServiceRequest')
    end
  end

  def down
    # Remove type from Surveys
    remove_column :surveys, :type

    # Remove surveyable_id and surveyable_type from Surveys
    remove_index :surveys, :index_surveys_on_surveyable_id_and_surveyable_type
    remove_column :surveys, :surveyable_id
    remove_column :surveys, :surveyable_type

    # Don't allow display_order to be null
    change_column :surveys, :display_order, :integer, null: false

    responses = Response.where(respondable_type: 'SubServiceRequest').to_a

    # Remove respondable_id and respondable_type from Responses
    remove_index :responses, :index_responses_on_respondable_id_and_respondable_type
    remove_column :responses, :respondable_id
    remove_column :responses, :respondable_type

    # Add sub_service_request_id to Responses
    add_reference :responses, :sub_service_request, index: true
    change_column :responses, :sub_service_request_id, :integer
    add_foreign_key :responses, :sub_service_requests

    # Rename associated_surveys association
    rename_column :associated_surveys, :associable_id, :surveyable_id
    rename_column :associated_surveys, :associable_type, :surveyable_type

    Survey.reset_column_information
    Response.reset_column_information
    AssociatedSurvey.reset_column_information
    
    # Replace respondable_id with sub_service_request_id
    responses.each do |r|
      reloaded_response = Response.find(r.id)
      reloaded_response.update_attributes(sub_service_request_id: r.respondable_id)
    end
  end
end
