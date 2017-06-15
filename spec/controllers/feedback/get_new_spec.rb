require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  describe '#GET new' do
    it 'should instantiate new Feedback object' do
      get :new, xhr: true

      expect(response).to be_success
    end
  end
end

