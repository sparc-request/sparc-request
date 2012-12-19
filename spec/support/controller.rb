# Stub out all the methods in ApplicationController so we're not testing
# them
def stub_controller
  before(:each) do
    controller.stub!(:current_user) do
      Identity.find_by_id(session[:identity_id])
    end

    controller.stub!(:load_defaults) do
      controller.instance_eval do
        @user_portal_link = '/portal'
        @default_mail_to  = 'nobody@nowhere.com'
      end
    end

    controller.stub!(:initialize_service_request) do
      controller.instance_eval do
        @service_request = ServiceRequest.find_by_id(session[:service_request_id])
        @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
        @line_items = @service_request.try(:line_items)
      end
    end

    controller.stub!(:authorize_identity) { }

    controller.stub!(:authenticate_identity!) { }

    controller.stub!(:setup_navigation) { }
  end
end

