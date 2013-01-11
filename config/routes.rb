SparcRails::Application.routes.draw do
  devise_for :identities, :controllers => { :omniauth_callbacks => "identities/omniauth_callbacks" }

  resources :identities do
    collection do
      post 'add_to_protocol'
    end

    member do
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
    end

    resource :service_calendars do
      member do
        get 'table'
      end
      collection do
        put 'rename_visit'
      end
    end

  end

  resources :projects

  resources :studies do
    resources :identities
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
  match 'service_requests/:id/select_calendar_row/:line_item_id' => 'service_requests#select_calendar_row'
  match 'service_requests/:id/unselect_calendar_row/:line_item_id' => 'service_requests#unselect_calendar_row'
  match 'service_requests/:id/select_calendar_column/:column_id' => 'service_requests#select_calendar_column'
  match 'service_requests/:id/unselect_calendar_column/:column_id' => 'service_requests#unselect_calendar_column'
  match 'service_requests/:id/delete_document_group/:document_group_id' => 'service_requests#delete_documents'
  match 'service_requests/:id/edit_document_group/:document_group_id' => 'service_requests#edit_documents'
  match 'rubyception' => 'rubyception/application#index'

  ##### sparc-services routes brought in and namespaced
  namespace :catalog_manager do
    match 'services/search' => 'services#search'
    match 'services/associate' => 'services#associate'
    match 'services/disassociate' => 'services#disassociate'
    match 'services/set_optional' => 'services#set_optional'
    match 'services/get_updated_rate_maps' => 'services#get_updated_rate_maps'

    resources :catalog do
      collection do
        post :add_excluded_funding_source
        delete :remove_excluded_funding_source
      end
    end

    resources :institutions
    resources :providers
    resources :programs
    resources :cores
    resources :services

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

    resources :admin do
      collection do

        resources :sub_service_requests do
          member do
            put :update_from_fulfillment
            post :add_line_item
            post :new_document
            post :add_note
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
          end
        end

        resources :visits do
          member do
            put :update_from_fulfillment
          end
        end

        put "/visits/:id/update_from_fulfillment" => "visits#update_from_fulfillment"
        put "/service_requests/:id/update_from_fulfillment" => "service_requests#update_from_fulfillment"
        post "/service_requests/:id/add_per_patient_per_visit_visit" => "service_requests#add_per_patient_per_visit_visit"
        put "/subsidys/:id/update_from_fulfillment" => "subsidies#update_from_fulfillment"
        delete "/subsidys/:id" => "subsidies#destroy"
        delete "/service_requests/:id/remove_per_patient_per_visit_visit" => "service_requests#remove_per_patient_per_visit_visit"
        delete "/delete_toast_message/:id" => "admin#delete_toast_message"
      end
    end
    match '/admin/sub_service_requests/:id/edit_document_group/:document_group_id' => 'sub_service_requests#edit_documents'
    match "/admin/sub_service_requests/:id/delete_document_group/:document_group_id" => "sub_service_requests#delete_documents"
    
    root :to => 'home#index'
  end

  root :to => 'service_requests#catalog'

end
