require 'rails_helper'

RSpec.describe ShortInteractionsController, type: :controller do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  describe '#new' do
    before :each do
      get :new, params: {
        identity_id: logged_in_user.id
      }, xhr: true

    end
      
    it 'should assign @short_interaction' do
      expect(assigns(:short_interaction).class).to eq(ShortInteraction)
    end

    it 'should render template' do
      expect(controller).to render_template(:new)
    end

    it 'should respond ok' do
      expect(controller).to respond_with(:ok)
    end

  end
end
