require 'rails_helper'

RSpec.describe Portal::ProtocolsController do

  stub_portal_controller

  let!(:identity) { create(:identity)}

  before(:each) { session[:identity_id] = identity.id }

  describe 'GET #index.js' do

  	let!(:archived_protocol)   { create(:protocol_without_validations, archived: true) }
  	let!(:unarchived_protocol) { create(:protocol_without_validations) }

    before do
    	create(:project_role_approve, protocol: unarchived_protocol,
                                    identity: identity)
    	create(:project_role_approve, protocol: archived_protocol,
                                    identity: identity)
    end

  	context 'default portal view' do

  	  before { get :index, format: :js }

  	  it 'does not contain archived protocol' do
  	    expect(assigns(:protocols)).to eq([unarchived_protocol])
  	  end
  	end

  	context 'filtered portal view' do

  	  before { get :index, include_archived: 'true', format: :js }

  	  it 'shows archived and unarchived protocols' do
  		  expect(assigns(:protocols).sort).to eq([archived_protocol, unarchived_protocol])
  	  end
  	end
  end
end
