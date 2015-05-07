# Copyright © 2011 MUSC Foundation for Research Development
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

SparcRails::Application.routes.draw do

  match '/direct_link_to/:survey_code', :to => 'surveyor#create', :as => 'direct_link_survey', :via => :get
  mount Surveyor::Engine => "/surveys", :as => "surveyor"

  devise_for :identities, :controllers => { :omniauth_callbacks => "identities/omniauth_callbacks" }

  resources :identities do
    collection do
      post 'add_to_protocol'
    end

    member do
      post 'show'
      get 'approve_account'
      get 'disapprove_account'
    end
  end

  resources :service_requests do
    resources :projects
    resources :studies
    member do
      get 'catalog'
      get 'protocol'
      get 'review'
      get 'obtain_research_pricing'
      get 'confirmation'
      get 'service_details'
      get 'service_calendar'
      get 'calendar_totals'
      get 'service_subsidy'
      get 'document_management'
      post 'navigate'
      get 'refresh_service_calendar'
      get 'save_and_exit'
      get 'approve_changes'
    end

    collection do
      post 'ask_a_question'
      post 'feedback'
    end

    resource :service_calendars do
      member do
        get 'table'
        get 'merged_calendar'
      end
      collection do
        put 'rename_visit'
        put 'set_day'
        put 'set_window_before'
        put 'set_window_after'
        put 'update_otf_qty_and_units_per_qty'
        put 'move_visit_position'
        put 'show_move_visits'
      end
    end

  end

  resources :protocols do
    member do
      get :approve_epic_rights
      get :push_to_epic
    end
  end

  resources :projects do
    member do
      get :push_to_epic_status
    end
  end

  resources :studies do
    resources :identities

    member do
      get :push_to_epic_status
    end
  end

  resources :catalogs do
    member do
      post 'update_description'
    end
  end

  resources :search do
    collection do
      get :services
      get :identities
    end
  end

  match 'service_requests/:id/add_service/:service_id' => 'service_requests#add_service'
  match 'service_requests/:id/remove_service/:line_item_id' => 'service_requests#remove_service'
  match 'service_requests/:id/select_calendar_row/:line_items_visit_id' => 'service_calendars#select_calendar_row'
  match 'service_requests/:id/unselect_calendar_row/:line_items_visit_id' => 'service_calendars#unselect_calendar_row'
  match 'service_requests/:id/select_calendar_column/:column_id/:arm_id' => 'service_calendars#select_calendar_column'
  match 'service_requests/:id/unselect_calendar_column/:column_id/:arm_id' => 'service_calendars#unselect_calendar_column'
  match 'service_requests/:id/delete_document/:document_id' => 'service_requests#delete_documents'
  match 'service_requests/:id/edit_document/:document_id' => 'service_requests#edit_documents'
  match 'service_requests/:id/new_document' => 'service_requests#new_document'
  match 'rubyception' => 'rubyception/application#index'

  ##### sparc-services routes brought in and namespaced
  namespace :catalog_manager do
    match 'services/search' => 'services#search'
    match 'services/associate' => 'services#associate'
    match 'services/disassociate' => 'services#disassociate'
    match 'services/set_optional' => 'services#set_optional'
    match 'services/set_linked_quantity' => 'services#set_linked_quantity'
    match 'services/set_linked_quantity_total' => 'services#set_linked_quantity_total'
    match 'services/get_updated_rate_maps' => 'services#get_updated_rate_maps'

    resources :catalog do
      collection do
        post :add_excluded_funding_source
        delete :remove_excluded_funding_source
        post :remove_associated_survey
        post :add_associated_survey
        post :remove_submission_email
      end
    end

    resources :institutions
    resources :providers
    resources :programs
    resources :cores
    resources :services do
      collection do
        get :verify_parent_service_provider
      end
    end

    match 'identities/associate_with_org_unit' => 'identities#associate_with_org_unit'
    match 'identities/disassociate_with_org_unit' => 'identities#disassociate_with_org_unit'
    match 'identities/set_view_draft_status' => 'identities#set_view_draft_status'
    match 'identities/set_primary_contact' => 'identities#set_primary_contact'
    match 'identities/set_hold_emails' => 'identities#set_hold_emails'
    match 'identities/set_edit_historic_data' => 'identities#set_edit_historic_data'
    match 'identities/search' => 'identities#search'
    match 'services/update_cores/:id' => 'services#update_cores'
    match 'update_pricing_maps' => 'catalog#update_pricing_maps'
    match 'update_dates_on_pricing_maps' => 'catalog#update_dates_on_pricing_maps'
    match 'validate_pricing_map_dates' => 'catalog#validate_pricing_map_dates'
    match '*verify_valid_pricing_setups' => 'catalog#verify_valid_pricing_setups'

    root :to => 'catalog#index'
  end

  ##### Study Tracker/Clinical Work Fulfillment Portal#####
  namespace :study_tracker, :path => "clinical_work_fulfillment" do
    match 'appointments/add_note' => 'calendars#add_note'
    match 'calendars/delete_toast_messages' => 'calendars#delete_toast_messages'
    match 'calendars/change_visit_group' => 'calendars#change_visit_group'
    match 'appointments/add_service' => 'calendars#add_service'

    root :to => 'home#index'

    resources :home do
      collection do
        get :billing_report_setup
        post :billing_report
      end
    end

    resources :sub_service_requests do
      resources :calendars
      resources :cover_letters
    end

    resources :service_requests
    resources :subjects

    resources :protocols do
      member do
        put :update_billing_business_manager_static_email
      end
    end
  end

  ##### sparc-user routes brought in and namespaced
  namespace :portal do

    resources :services, :admin

    resources :associated_users do
      collection do
        get :search
      end
    end

    resources :service_requests do
      member do
        put :update_line_item
        get 'refresh_service_calendar'
      end
    end

    resources :protocols do
      member do
        get :add_user
        get :view_full_calendar
      end
      resources :associated_users
    end

    resources :studies, :controller => :protocols
    resources :projects, :controller => :protocols

    resources :notifications do
      member do
        put :user_portal_update
        put :admin_update
      end
      collection do
        put :mark_as_read
      end
    end

    resources :documents do
      collection do
        post :upload
        post :override
      end
      get :download
    end

    resource :admin do
      resources :sub_service_requests do
        member do
          put :update_from_fulfillment
          put :update_from_project_study_information
          put :push_to_epic
          put :add_line_item
          put :add_otf_line_item
          post :new_document
          put :add_note
        end
      end

      resources :protocols do
        member do
          put :update_protocol_type
          put :update_from_fulfillment
        end
      end

      resources :subsidies do
        member do
          put :update_from_fulfillment
        end
      end

      resources :fulfillments do
        member do
          put :update_from_fulfillment
        end
      end

      resources :line_items do
        member do
          put :update_from_fulfillment
          put :update_from_cwf
        end
      end

      resources :line_items_visits do
        member do
          put :update_from_fulfillment
        end
      end

      resources :visits do
        member do
          put :update_from_fulfillment
        end
      end

      collection do
        put "/visits/:id/update_from_fulfillment" => "visits#update_from_fulfillment"
        put "/service_requests/:id/update_from_fulfillment" => "service_requests#update_from_fulfillment"
        get "/protocols/:id/change_arm" => "protocols#change_arm"
        post "/protocols/:id/add_arm" => "protocols#add_arm"
        post "/protocols/:id/remove_arm" => "protocols#remove_arm"
        post "/service_requests/:id/add_per_patient_per_visit_visit" => "service_requests#add_per_patient_per_visit_visit"
        put "/subsidys/:id/update_from_fulfillment" => "subsidies#update_from_fulfillment"
        delete "/subsidys/:id" => "subsidies#destroy"
        delete "/service_requests/:id/remove_per_patient_per_visit_visit" => "service_requests#remove_per_patient_per_visit_visit"
        delete "/delete_toast_message/:id" => "admin#delete_toast_message"
      end
    end
    match '/admin/sub_service_requests/:id/edit_document/:document_id' => 'sub_service_requests#edit_documents'
    match "/admin/sub_service_requests/:id/delete_document/:document_id" => "sub_service_requests#delete_documents"

    root :to => 'home#index'
  end

  resources :reports do
    collection do
      get :setup
      post :generate
    end

    member do
      get :research_project_summary
      post :cwf_audit
      get :cwf_subject
    end
  end

  mount API::Base => '/'

  root :to => 'service_requests#catalog'
end
