require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #new' do
    context 'params[:protocol_type] == "project"' do
      before(:each) do
        @current_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @current_user)
        get :new, protocol_type: 'project'
      end

      it 'should set @protocol_type to "project"' do
        expect(assigns(:protocol_type)).to eq('project')
      end

      it 'should set @protocol to a new Project with requester equal to logged in user' do
        expect(assigns(:protocol).class.name).to eq('Project')
        expect(assigns(:protocol).id).to eq(nil)
        expect(assigns(:protocol).requester_id).to eq(@current_user.id)
      end

      it 'should set session[:protocol_type] to "project"' do
        expect(session[:protocol_type]).to eq('project')
      end

      it { is_expected.to render_template "dashboard/protocols/new" }
      it { is_expected.to respond_with :ok }
    end

    context 'params[:protocol_type] == "study"' do
      before(:each) do
        @current_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @current_user)
        get :new, protocol_type: 'study'
      end

      it 'should set @protocol_type to "study"' do
        expect(assigns(:protocol_type)).to eq('study')
      end

      it 'should set @protocol to a new Study with requester equal to logged in user' do
        expect(assigns(:protocol).class.name).to eq('Study')
        expect(assigns(:protocol).id).to eq(nil)
        expect(assigns(:protocol).requester_id).to eq(@current_user.id)
      end

      it 'should set session[:protocol_type] to "study"' do
        expect(session[:protocol_type]).to eq('study')
      end

      it { is_expected.to render_template "dashboard/protocols/new" }
      it { is_expected.to respond_with :ok }
    end
  end
end
