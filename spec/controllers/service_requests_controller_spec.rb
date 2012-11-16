describe ServiceRequestsController do
  describe 'GET catalog' do
    # TODO: This test really belongs in ApplicationControllerSpec, but I
    # don't know how to make it work there yet...
    it 'should assign current_user' do
      get :catalog
      assigns(:current_user).class.should eq Identity
    end
  end
end

