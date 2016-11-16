require 'rails_helper'

RSpec.describe StudyTypeController, type: :controller do

  describe "GET #determine_study_type_note" do
    it "returns http success" do
      get :determine_study_type
      expect(response).to have_http_status(:success)
    end
  end

end