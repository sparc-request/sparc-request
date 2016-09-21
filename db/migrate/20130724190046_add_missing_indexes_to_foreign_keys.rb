# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class AddMissingIndexesToForeignKeys < ActiveRecord::Migration
  def change
    add_index :answers, :question_id
    add_index :approvals, :identity_id
    add_index :approvals, :sub_service_request_id
    add_index :arms, :service_request_id
    add_index :associated_surveys, :surveyable_id
    add_index :associated_surveys, :survey_id
    add_index :calendars, :subject_id
    add_index :charges, :service_id
    add_index :clinical_providers, :identity_id
    add_index :dependencies, :question_id
    add_index :dependencies, :question_group_id
    add_index :dependency_conditions, :dependency_id
    add_index :dependency_conditions, :question_id
    add_index :dependency_conditions, :answer_id
    add_index :document_groupings, :service_request_id
    add_index :documents, :sub_service_request_id
    add_index :documents, :document_grouping_id
    add_index :line_items, :sub_service_request_id
    add_index :line_items, :service_id
    add_index :line_items, :ssr_id
    add_index :line_items_visits, :arm_id
    add_index :line_items_visits, :line_item_id
    add_index :messages, :notification_id
    add_index :notes, :identity_id
    add_index :notes, :sub_service_request_id
    add_index :notifications, :sub_service_request_id
    add_index :notifications, :originator_id
    add_index :pricing_setups, :organization_id
    add_index :project_roles, :identity_id
    add_index :protocols, :next_ssr_id
    add_index :questions, :survey_section_id
    add_index :questions, :question_group_id
    add_index :questions, :correct_answer_id
    add_index :response_sets, :user_id
    add_index :response_sets, :survey_id
    add_index :responses, :response_set_id
    add_index :responses, :question_id
    add_index :responses, :answer_id
    add_index :service_providers, :identity_id
    add_index :service_relations, :related_service_id
    add_index :sub_service_requests, :owner_id
    add_index :sub_service_requests, :ssr_id
    add_index :subjects, :arm_id
    add_index :subsidies, :sub_service_request_id
    add_index :super_users, :identity_id
    add_index :survey_sections, :survey_id
    add_index :survey_translations, :survey_id
    add_index :taggings, :tagger_id
    add_index :toast_messages, :sending_class_id
    add_index :tokens, :identity_id
    add_index :user_notifications, :identity_id
    add_index :user_notifications, :notification_id
    add_index :validation_conditions, :validation_id
    add_index :validation_conditions, :question_id
    add_index :validation_conditions, :answer_id
    add_index :validations, :answer_id
    add_index :visits, :line_items_visit_id
    add_index :visits, :visit_group_id
  end
end
