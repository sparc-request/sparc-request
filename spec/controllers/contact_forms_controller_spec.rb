require 'rails_helper'

RSpec.describe ContactFormsController, type: :controller do
  let!(:contact_form) do
    FactoryGirl.create(:contact_form)
  end

  describe 'GET #new' do
    it 'returns http success' do
      xhr :get, :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new instance to correct model' do
      xhr :get, :new
      expect(assigns(:contact_form).class).to eq ContactForm
    end
  end

  describe 'GET #create' do
    it 'returns http success' do
      xhr :post, :create, :contact_form => {
        subject: 'subject',
        email: 'email@email.com',
        message: 'sample message'
      }
      expect(response).to have_http_status(:success)
    end

    it 'should send an email' do
      expect { xhr :post, :create, :contact_form => {
        subject: 'subject',
        email: 'email@email.com',
        message: 'sample message'
      }}.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
