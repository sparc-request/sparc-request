# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
