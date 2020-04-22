Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  ####################
  ### Devise Setup ###
  ####################

  devise_for :identities, controllers: {
    omniauth_callbacks: 'identities/omniauth_callbacks',
    registrations: 'identities/registrations',
    passwords: 'identities/passwords'
  }

  resources :identities, only: [] do
    member do
      get 'approve_account'
      get 'disapprove_account'
    end
  end

  ####################
  ### Other Routes ###
  ####################

  resource :pages, only: [] do
    get :event_details
    get :faqs
    get :get_news_feed
    get :get_calendar_events
  end

  resources :forms, only: [:index]

  resources :feedback, only: [:new, :create]

  resources :contact_forms, only: [:new, :create]

  resources :short_interactions, only: [:new, :create]

  resources :subsidies, only: [:new, :create, :edit, :update, :destroy]

  resource :service_request, only: [:show] do
    get :catalog
    get :protocol
    get :service_details
    get :service_subsidy
    get :document_management
    get :review
    get :confirmation
    get :approve_changes
    get :system_satisfaction_survey

    put :save_and_exit

    post :navigate
    post :add_service

    delete :remove_service
  end

  resource :research_master, only: [:update]

  resources :protocols, except: [:index, :destroy] do
    collection do
      get :validate_rmid
    end

    member do
      get :approve_epic_rights
      get :push_to_epic
      get :push_to_epic_status
      patch :update_protocol_type
    end
  end

  resource :protocol do
    get :get_study_type_note
  end

  resources :projects, controller: :protocols, except: [:index, :show, :destroy]

  resources :studies, controller: :protocols, except: [:index, :show, :destroy]

  resource :irb_records, only: [:new, :create, :edit, :update, :destroy]

  resources :associated_users, except: [:show] do
    collection do
      get :update_professional_organizations
    end
  end

  resources :arms, except: [:show]

  resource :service_calendars, only: [] do
    member do
      get 'table'
      get 'merged_calendar'
      get 'view_full_calendar'
    end
    collection do
      post 'toggle_calendar_row'
      post 'toggle_calendar_column'
    end
  end

  resources :line_items, only: [:edit, :update]
  resources :line_items_visits, only: [:edit, :update, :destroy]
  resources :visit_groups, only: [:new, :create, :edit, :update, :destroy]
  resources :visits, only: [:edit, :update, :destroy]

  resources :documents, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :notes, only: [:index, :create, :edit, :update, :destroy]

  resource :catalogs, only: [] do
    get :update_catalog
    get :update_description
    get :locked_organization
  end

  resources :search, only: [] do
    collection do
      get :services_search
      get :services
      get :organizations
      get :identities
    end
  end

  wash_out :oncore_endpoint # SOAP Endpoint for OnCore RPE messages

  match 'services/:service_id' => 'service_requests#catalog', via: [:get]
  match 'organizations/:organization_id' => 'service_requests#catalog', via: [:get]

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
    resources :associated_users, except: [:show]

    resources :documents, except: [:show]

    resources :epic_queues, only: [:index, :destroy]
    resources :epic_queue_records, only: [:index]

    resource :protocol_merge do
      put :perform_protocol_merge
    end

    resources :fulfillments

    resources :clinical_line_items, only: [] do
      collection do
        get :new
        get :edit
        post :create
        delete :destroy
      end
    end

    resources :study_level_activities do
      member do
        put :update_from_cwf
      end
    end

    resources :notifications, only: [:index, :new, :create] do
      member do
        put :admin_update
      end
      collection do
        put :mark_as_read
      end
    end

    resources :messages, only: [:index, :new, :create]

    resources :protocols, except: [:destroy] do
      resource :study_type_answers, only: [:edit]

      member do
        get :display_requests
        patch :archive
        patch :update_protocol_type
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

    resources :subsidies, except: [:index, :show] do
      member do
        patch :approve
      end
    end

    resources :sub_service_requests, except: [:new, :create, :edit] do
      member do
        put :push_to_epic
        put :resend_surveys
        get :change_history_tab
        get :status_history
        get :approval_history
        get :subsidy_history
        get :refresh_tab
      end
    end

    root to: 'protocols#index'
  end

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
      put :resend_survey
    end
    resources :response_filters, only: [:new, :create, :destroy]
    resources :survey_updater, only: [:update]
    root to: 'surveys#index'
  end

  resources :reports, only: [:index] do
    collection do
      get :setup
      post :generate
    end
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

  mount APIV1::Base => '/'

  root to: 'service_requests#catalog'

  get "/authorization_error", to: "error_pages#authorization_error"
  get "/404", to: "error_pages#not_found"
  get "/500", to: "error_pages#internal_server_error"
end
