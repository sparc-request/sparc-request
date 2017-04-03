require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  describe '#GET new' do
    it 'should instantiate new Feedback object' do
      xhr :get, :new

      expect(response).to be_success
    end
  end
end

