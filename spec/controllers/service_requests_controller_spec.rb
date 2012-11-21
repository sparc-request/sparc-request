describe ServiceRequestsController do
  describe 'GET catalog' do
    # TODO: This test really belongs in ApplicationControllerSpec, but I
    # don't know how to make it work there yet...
    it 'should assign current_user' do
      get :catalog
      assigns(:current_user).class.should eq Identity
    end

    let!(:service_request) { FactoryGirl.create(:service_request) }

    it 'should set institutions to all institutions if there is no sub service request id' do
      session[:service_request_id] = service_request.id
      p session
      get :catalog
      p session
      assigns(:institutions).should eq nil # TODO: need sample data
    end
  end
end

