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

SparcRails::Application.routes.draw do
  match '/direct_link_to/:survey_code', :to => 'surveyor#create', :as => 'direct_link_survey', :via => :get
  match '/surveys/:survey_code/:response_set_code', :to => 'surveyor#destroy', :via => :delete
  mount Surveyor::Engine => "/surveys", :as => "surveyor"

  resources :services do
    namespace :additional_details do
      resources :questionnaires
      resource :questionnaire do
        resource :preview, only: [:create]
      end
      resources :submissions
      resources :update_questionnaires, only: [:update]
    end
  end

  if USE_SHIBBOLETH_ONLY
    devise_for :identities,
               controllers: {
                 omniauth_callbacks: 'identities/omniauth_callbacks'
               }, path_names: { sign_in: 'auth/shibboleth' }
  else
    devise_for :identities,
               controllers: {
                 omniauth_callbacks: 'identities/omniauth_callbacks'
               }
  end

  resources :identities, only: [:show] do
    collection do
      post 'add_to_protocol'
    end

    member do
      post 'show'
      get 'approve_account'
      get 'disapprove_account'
    end
  end

  resources :contact_forms, only: [:new, :create]

  resources :subsidies, only: [:create, :update, :destroy]

  resources :service_requests, only: [:show] do
    resources :projects, except: [:index, :show, :destroy]
    resources :studies, except: [:index, :show, :destroy]
    member do
      get 'catalog'
      get 'protocol'
      get 'review'
      get 'obtain_research_pricing'
      get 'confirmation'
      get 'service_details'
      get 'service_calendar'
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

    resource :service_calendars, only: [:update, :index] do
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

  resources :protocols, except: [:index, :show, :destroy] do
    member do
      get :approve_epic_rights
      get :push_to_epic
    end
  end

  resources :projects, except: [:index, :show, :destroy] do
    member do
      get :push_to_epic_status
    end
  end

  resources :studies, except: [:index, :show, :destroy] do
    resources :identities, only: [:show]

    member do
      get :push_to_epic_status
    end
  end

  resources :catalogs, only: [] do
    member do
      post 'update_description'
    end
  end

  resources :search, only: [] do
    collection do
      get :services
      get :identities
    end
  end

  match 'service_requests/:id/add_service/:service_id' => 'service_requests#add_service', via: [:get, :post]
  match 'service_requests/:id/remove_service/:line_item_id' => 'service_requests#remove_service', via: [:all]
  match 'service_requests/:id/toggle_calendar_row/:line_items_visit_id' => 'service_calendars#toggle_calendar_row', via: [:post]
  match 'service_requests/:id/toggle_calendar_column/:column_id/:arm_id' => 'service_calendars#toggle_calendar_column', via: [:get]
  match 'service_requests/:id/delete_document/:document_id' => 'service_requests#delete_documents', via: [:all]
  match 'service_requests/:id/edit_document/:document_id' => 'service_requests#edit_documents', via: [:get, :post]
  match 'service_requests/:id/new_document' => 'service_requests#new_document', via: [:get, :post]

  ##### sparc-services routes brought in and namespaced
  namespace :catalog_manager do
    match 'services/search' => 'services#search', via: [:get, :post]
    match 'services/associate' => 'services#associate', via: [:get, :post]
    match 'services/disassociate' => 'services#disassociate', via: [:get, :post]
    match 'services/set_optional' => 'services#set_optional', via: [:get, :post]
    match 'services/set_linked_quantity' => 'services#set_linked_quantity', via: [:get, :post]
    match 'services/set_linked_quantity_total' => 'services#set_linked_quantity_total', via: [:get, :post]
    match 'services/get_updated_rate_maps' => 'services#get_updated_rate_maps', via: [:get, :post]

    resources :catalog, only: [:index] do
      collection do
        post :add_excluded_funding_source
        delete :remove_excluded_funding_source
        post :remove_associated_survey
        post :add_associated_survey
        post :remove_submission_email
      end
    end

    resources :organizations, only: [:show, :update, :create]
    resources :institutions, only: [:show, :update, :create]
    resources :providers, only: [:show, :update, :create]
    resources :programs, only: [:show, :update, :create]
    resources :cores, only: [:show, :update, :create]
    resources :services, except: [:index, :edit, :destroy] do
      collection do
        get :verify_parent_service_provider
      end
    end

    match 'identities/associate_with_org_unit' => 'identities#associate_with_org_unit', via: [:get, :post]
    match 'identities/disassociate_with_org_unit' => 'identities#disassociate_with_org_unit', via: [:get, :post]
    match 'identities/set_view_draft_status' => 'identities#set_view_draft_status', via: [:get, :post]
    match 'identities/set_primary_contact' => 'identities#set_primary_contact', via: [:get, :post]
    match 'identities/set_hold_emails' => 'identities#set_hold_emails', via: [:get, :post]
    match 'identities/set_edit_historic_data' => 'identities#set_edit_historic_data', via: [:get, :post]
    match 'identities/search' => 'identities#search', via: [:get, :post]
    match 'services/update_cores/:id' => 'services#update_cores', via: [:get, :post]
    match 'update_pricing_maps' => 'catalog#update_pricing_maps', via: [:get, :post]
    match 'update_dates_on_pricing_maps' => 'catalog#update_dates_on_pricing_maps', via: [:get, :post]
    match 'validate_pricing_map_dates' => 'catalog#validate_pricing_map_dates', via: [:get, :post]
    match '*verify_valid_pricing_setups' => 'catalog#verify_valid_pricing_setups', via: [:get, :post]

    root to: 'catalog#index'
  end

  namespace :dashboard do

    resources :approvals, only: [:new, :create]

    resources :arms, only: [:new, :create, :update, :destroy] do
      collection do
        get :navigate
      end
    end

    resources :associated_users, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get :search_identities
      end
    end

    resources :documents, except: [:show]

    resources :epic_queues, only: [:index, :destroy]

    resources :fulfillments

    resources :line_items do
      member do
        get :details
        put :update_from_cwf
      end
    end

    resources :line_items_visits, only: [:destroy]

    resources :messages, only: [:index, :new, :create]

    resources :multiple_line_items, only: [] do
      collection do
        get :new_line_items
        put :create_line_items
        get :edit_line_items
        put :destroy_line_items
      end
    end

    resources :notes, only: [:index, :new, :create]

    resources :notifications, only: [:index, :new, :create] do
      member do
        put :user_portal_update
        put :admin_update
      end
      collection do
        put :mark_as_read
      end
    end

    resources :projects, controller: :protocols, except: [:destroy]

    resources :protocols, except: [:destroy] do
      member do
        get :view_full_calendar
        patch :update_protocol_type
        get :display_requests
        patch :archive
        get :view_details
      end
    end

    # HACK: This is needed to prevent the filterrific gem's
    # path helpers from blowing up when running view specs
    # This shouldn't affect dev or production environments.
    # Alternative solutions welcome.
    if Rails.env.test?
      scope '/protocols', controller: :protocols, except: [:destroy] do
        resources :test, except: [:destroy] do
          member do
            get :view_full_calendar
            patch :update_protocol_type
            get :display_requests
            patch :archive
          end
        end
      end
    end

    resources :protocol_filters, only: [:new, :create]

    resources :services, only: [:show]

    resource :service_calendars, only: [:update, :index] do
      member do
        get 'table'
        get 'merged_calendar'
        get 'view_full_calendar'
      end

      collection do
        put 'rename_visit'
        put 'set_day'
        put 'set_window_before'
        put 'set_window_after'
        put 'update_otf_qty_and_units_per_qty'
        put 'move_visit_position'
        put 'show_move_visits'
        post 'toggle_calendar_row'
        post 'toggle_calendar_column'
      end
    end

    resources :service_requests, only: [:show]

    resources :studies, controller: :protocols, except: [:destroy]

    resources :subsidies, except: [:index] do
      member do
        patch :approve
      end
    end

    resources :sub_service_requests, except: [:new, :create, :edit]do
      member do
        put :push_to_epic
        get :change_history_tab
        get :status_history
        get :approval_history
        get :subsidy_history
        get :refresh_service_calendar
        get :refresh_tab
      end
    end

    resources :visits, only: [:destroy]

    resources :visit_groups, only: [:new, :create, :update, :destroy] do
      collection do
        get :navigate
      end
    end

    root to: 'protocols#index'
  end

  resources :reports, only: [:index] do
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

  ##### Admin Identities #####
  namespace :admin do
    root :to => 'identities#index'
    match 'identities/search' => 'identities#search', :via => :get
    resources :identities, only: [:index, :show, :create, :update]
  end

  mount API::Base => '/'

  root to: 'service_requests#catalog'
end
