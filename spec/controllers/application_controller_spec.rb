require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render :json => { }
    end
  end

  describe :current_user do
    it 'should call current_identity' do
      controller.stub!(:current_identity)
      controller.should_receive(:current_identity)
      controller.current_user
    end
  end
end

