SparcRails::Application.routes.draw do
  devise_for :identities, :controllers => { :omniauth_callbacks => "identities/omniauth_callbacks" }

  resources :identities do
    collection do
      post 'add_to_protocol'
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
    end

    collection do
      post 'ask_a_question'
    end

    resource :service_calendars do
      member do
        get 'table'
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
  root :to => 'service_requests#catalog'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
