# Copyright © 2011-2018 MUSC Foundation for Research Development
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
  post 'study_type/determine_study_type_note'

  resources :services

  namespace :surveyor do
    resources :surveys, only: [:index, :new, :create, :edit, :destroy] do
      get :preview
      get :update_dependents_list
      post :copy
    end
    resource :survey, only: [] do
      get :search_surveyables
    end
    resources :sections, only: [:create, :destroy]
    resources :questions, only: [:create, :destroy]
    resources :options, only: [:create, :destroy]
    resources :responses do
      get :complete
    end
    resources :response_filters, only: [:new, :create, :destroy]
    resources :survey_updater, only: [:update]
    root to: 'surveys#index'
  end

  resources :forms, only: [:index]

  resources :feedback

  begin
    use_shibboleth_only = Setting.get_value("use_shibboleth_only")
    use_cas_only        = Setting.get_value("use_cas_only")
  rescue
    use_shibboleth_only = nil
    use_cas_only        = nil
  end

  if use_shibboleth_only
    devise_for :identities,
               controllers: {
                 omniauth_callbacks: 'identities/omniauth_callbacks',
                 sessions: 'identities/sessions',
                 registrations: 'identities/registrations'
               }, path_names: { sign_in: 'auth/shibboleth' }

  elsif use_cas_only
    devise_for :identities,
               controllers: {
                 omniauth_callbacks: 'identities/omniauth_callbacks',
                 sessions: 'identities/sessions',
                 registrations: 'identities/registrations'
               }, path_names: { sign_in: 'auth/cas' }
  else
    devise_for :identities,
               controllers: {
                 omniauth_callbacks: 'identities/omniauth_callbacks',
                 sessions: 'identities/sessions',
                 registrations:      'identities/registrations'
               }
  end

  resources :identities, only: [] do

    member do
      get 'approve_account'
      get 'disapprove_account'
    end
  end

  resources :contact_forms, only: [:new, :create]
  resources :short_interactions, only: [:new, :create]

  resource :locked_organizations, only: [:show]

  resources :subsidies, only: [:new, :create, :edit, :update, :destroy]

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
      get 'get_help'
      get 'approve_changes'
    end

    collection do
      post 'feedback'
    end
  end

  resources :protocols, except: [:index, :destroy] do
    resource :research_master, only: [:update]
    member do
      put :update_protocol_type
      get :approve_epic_rights
      get :push_to_epic
      get :push_to_epic_status
    end
  end

  resources :projects, controller: :protocols, except: [:index, :show, :destroy]

  resources :studies, controller: :protocols, except: [:index, :show, :destroy]

  resources :associated_users, except: [:show] do
    collection do
      get :search_identities
    end
  end

  resources :arms, only: [:index, :new, :create, :edit, :update, :destroy]

  resource :service_calendars, only: [] do
    member do
      get 'table'
      get 'merged_calendar'
      get 'view_full_calendar'
    end
    collection do
      get 'show_move_visits'
      post 'move_visit_position'
      post 'toggle_calendar_row'
      post 'toggle_calendar_column'
    end
  end

  resources :line_items, only: [:update]
  resources :line_items_visits, only: [:update, :destroy]
  resources :visit_groups, only: [:edit, :update]
  resources :visits, only: [:edit, :update, :destroy]

  resources :documents, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :notes, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :sub_service_requests, only: [:show]

  resources :catalogs, only: [] do
    member do
      post 'update_description'
    end
  end

  resources :search, only: [] do
    collection do
      get :services_search
      get :services
      get :organizations
      get :identities
    end
  end

  match 'service_requests/:id/add_service/:service_id' => 'service_requests#add_service', via: [:get, :post]
  match 'service_requests/:id/remove_service/:line_item_id' => 'service_requests#remove_service', via: [:all]

  ##### sparc-services routes brought in and name-spaced
  namespace :catalog_manager do
    match 'services/search' => 'services#search', via: [:get, :post]
    match 'services/update_related_service' => 'services#update_related_service', via: [:post]
    match 'services/add_related_service' => 'services#add_related_service', via: [:post]
    match 'services/remove_related_service' => 'services@remove_related_service', via: [:post]
    match 'organizations/remove_fulfillment_rights_row' => 'organizations#remove_fulfillment_rights_row', via: [:post]
    match 'organizations/remove_user_rights_row' => 'organizations#remove_user_rights_row', via: [:post]
    match 'organizations/toggle_default_statuses' => 'organizations#toggle_default_statuses', via: [:post]
    match 'organizations/update_status_row' => 'organizations#update_status_row', via: [:post]
    match 'organizations/add_associated_survey' => 'organizations#add_associated_survey', via: [:post]
    match 'organizations/remove_associated_survey' => 'organizations#remove_associated_survey', via: [:post]
    match 'organizations/increase_decrease_modal' => 'organizations#increase_decrease_modal', via: [:get]
    match 'organizations/increase_decrease_rates' => 'organizations#increase_decrease_rates', via: [:post]
    match 'pricing_maps/refresh_rates' => 'pricing_maps#refresh_rates', via: [:get]

    resources :services, only: [:edit, :update, :create, :new] do
      get :reload_core_dropdown
      post :change_components
      patch :update_epic_info
    end

    resources :catalog, only: [:index] do
      collection do
        get :load_core_accordion
        get :load_program_accordion
      end
    end

    resources :organizations, only: [:edit, :update, :create, :new] do
      get :add_user_rights_row
      get :add_fulfillment_rights_row
    end
    resources :institutions, only: [:edit, :update]
    resources :providers, only: [:edit, :update]
    resources :programs, only: [:edit, :update]
    resources :cores, only: [:edit, :update]
    resource :super_user, only: [:create, :destroy, :update]
    resource :catalog_manager, only: [:create, :destroy, :update]
    resource :service_provider, only: [:create, :destroy, :update]
    resource :clinical_provider, only: [:create, :destroy]
    resource :patient_registrar, only: [:create, :destroy]
    resources :services, except: [:index, :show, :destroy]
    resources :pricing_setups, except: [:index, :show, :destroy]
    resources :subsidy_maps, only: [:edit, :update]
    resources :pricing_maps, only: [:new, :create, :edit, :update]
    resources :submission_emails, only: [:create, :destroy]

    root to: 'catalog#index'
  end

  namespace :dashboard do

    resources :approvals, only: [:new, :create]

    resources :arms, only: [:new, :create, :update, :destroy, :index] do
      collection do
        get :navigate
      end
    end

    resources :associated_users, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection do
        get :search_identities
        get :update_professional_organization_form_items
      end
    end

    resources :documents, except: [:show]

    resources :epic_queues, only: [:index, :destroy]
    resources :epic_queue_records, only: [:index]

    resources :fulfillments

    resources :line_items do
      member do
        get :details
        put :update_from_cwf
      end
    end

    resources :messages, only: [:index, :new, :create]

    resources :multiple_line_items, only: [] do
      collection do
        get :new_line_items
        put :create_line_items
        get :edit_line_items
        put :destroy_line_items
      end
    end

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
      resource :milestones, only: [:update]
      resource :study_type_answers, only: [:edit]
      member do
        put :update_protocol_type
        get :display_requests
        patch :archive
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
            put :update_protocol_type
            get :display_requests
            patch :archive
          end
        end
      end
    end

    resources :protocol_filters, only: [:new, :create, :destroy]

    resources :service_requests, only: [:show]

    resources :studies, controller: :protocols, except: [:destroy]

    resources :subsidies, except: [:index, :show] do
      member do
        patch :approve
      end
    end

    resources :sub_service_requests, except: [:new, :create, :edit]do
      member do
        put :push_to_epic
        put :resend_surveys
        get :change_history_tab
        get :status_history
        get :approval_history
        get :subsidy_history
        get :refresh_service_calendar
        get :refresh_tab
      end
    end

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
  end

  ##### Admin Identities #####
  namespace :admin do
    root :to => 'identities#index'
    match 'identities/search' => 'identities#search', :via => :get
    resources :identities, only: [:index, :show, :create, :update]
  end

  ##### Funding Download #####
  namespace :funding do
    root :to => 'services#index'
    resources :services do
      member do
        get :documents
      end
    end
  end

  mount API::Base => '/'

  root to: 'service_requests#catalog'

  ## error page routes ##
  match "/404", :to => "error_pages#not_found", :via => :all
  match "/500", :to => "error_pages#internal_server_error", :via => :all
end
