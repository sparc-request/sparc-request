require 'rails_helper'

RSpec.describe AdditionalDetail::LineItemAdditionalDetailsController do
  
  before :each do
    @additional_detail = AdditionalDetail.new
    @additional_detail.save(:validate => false)
    
    @line_item = LineItem.new
    @line_item.save(:validate => false)
    
    @line_item_additional_detail = LineItemAdditionalDetail.new
    @line_item_additional_detail.line_item_id = @line_item.id
    @line_item_additional_detail.additional_detail_id = @additional_detail.id
    @line_item_additional_detail.save(:validate => false)
  end
    
  describe 'user is not logged in and, thus, has no access to' do
    it 'a line_item_additional_detail' do
      get(:show, {:id => @line_item_additional_detail, :format => :html})
      expect(response).to redirect_to("/identities/sign_in")
    end
  end
  
  describe 'authenticated identity' do
    before :each do
      @identity = Identity.new
      @identity.approved = true
      @identity.save(validate: false)
      session[:identity_id] = @identity.id
      # Devise test helper method: sign_in
      sign_in @identity
    end

    describe 'has no affiliation with the project and, thus, has no access to' do
      it 'view a line_item_additional_detail HTML and JSON' do
        get(:show, {:id => @line_item_additional_detail, :format => :json})
        expect(response.status).to eq(401)
        expect(response.body).to eq("".to_json)
      end
    end
    
    describe 'is a service provider and, thus, has access to' do

      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json) 
      end
    end
    
    describe 'is the service requestor and, thus, has access to' do

      it 'view a line_item_additional_detail' do
        get(:show, {:id => @line_item_additional_detail, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json)
      end
    end
    
    describe 'is a project team member and, thus, has access to' do

      it 'view a line_item_additional_detail HTML and JSON' do
        get(:show, {:id => @line_item_additional_detail, :format => :json})
        expect(response.status).to eq(200)
        expect(response.body).to eq(@line_item_additional_detail.to_json)
      end
    end
  
  end
end
