require 'spec_helper'
# require './app/controllers/application_controller' # TODO: why is this needed?

describe ApplicationController do
  controller do
    def index
      render :json => { }
    end
  end

  describe 'GET index' do
    # TODO: This test really belongs in ApplicationControllerSpec, but I
    # don't know how to make it work there yet...
    it 'should assign current_user' do
      get :index
      assigns(:current_user).class.should eq Identity
    end
  end
end

