describe ServiceRequestsController do
  context 'testing base class' do
  end

  context 'testing everything else' do
    let!(:service_request) { FactoryGirl.create(:service_request) }

    before(:each) do
      controller.stub!(:authenticate)
      controller.stub!(:load_defaults)
      controller.stub!(:setup_session)
      controller.stub!(:setup_navigation)
    end

    it 'should set institutions to all institutions if there is no sub service request id' do
      session[:service_request_id] = service_request.id
      get :catalog, { :id => service_request.id }.with_indifferent_access
      assigns(:institutions).should eq Institution.all
    end
  end
end

