require 'rails_helper'

RSpec.describe ProtocolArchiveController, :type => :controller do
	
  describe "GET #create" do
  	context "protocol is not archived" do
	  	let!(:protocol) { create(:protocol_without_validations, archived: false) }
	  	before {post :create, format: :js, protocol_id: protocol.id}
	    it "returns http success" do
	      expect(response).to have_http_status(:success)
	    end
	    it "assigns @protocol" do
	    	expect(assigns(:protocol)).to eq(protocol) 
	    end
	    it "archives a protocol" do
	    	expect(assigns(:protocol).reload.archived).to eq(true)
	    end
	  end
		context "protocol is archived" do
			let!(:protocol) { create(:protocol_without_validations, archived: true) }
	  	before {xhr :get, :create, {protocol_id: protocol.id}}
	    it "unarchives a protocol"  do
	    	expect(assigns(:protocol).reload.archived).to eq(false)
	    end
	  end
  end

end
