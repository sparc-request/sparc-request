module DeviseFilters
  def self.add_filters
    # Example of adding a before_filter to all the Devise controller
    # actions we care about.
    [
      Devise::SessionsController,
      Devise::RegistrationsController,
      Devise::PasswordsController
    ].each do |controller|
      controller.before_filter :prepare_catalog
      controller.before_filter :initialize_service_request
    end

    # Example of adding one selective before_filter.
    #Devise::RegistrationsController.before_filter :check_invite_code, :only => :new
  end

  self.add_filters
end
