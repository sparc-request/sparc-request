require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane
  let_there_be_j

  describe 'GET protocol' do

    before(:each) do
      session[:identity_id] = jug2.id
      session[:saved_protocol_id] = project.id
    end

    # these studies should not appear in @studies
    let!(:anothers_study) do
      create(:study, :without_validations,
             identity: jpl6,
             project_rights: "approve",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    let!(:none_rights) do
      create(:study, :without_validations,
             identity: jug2,
             project_rights: "none",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    let!(:view_rights) do
      create(:study, :without_validations,
             identity: jug2,
             project_rights: "view",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    # this study should appear in @studies
    let!(:study2) do
      create(:study, :without_validations,
             identity: jug2,
             project_rights: "approve",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    let!(:project) do
      create(:project, :without_validations,
             type: "Project",
             identity: jug2,
             project_rights: "approve",
             role: "primary-pi",
             funding_status: "funded",
             funding_source: "federal",
             indirect_cost_rate: 50.0,
             start_date: Time.now,
             end_date: Time.now + 2.month)
    end

    context 'with session[:errors][:ctrc_services]' do
      build_service_request_with_study

      before(:each) do
        session[:errors]             = { ctrc_services: "an error"}
        session[:service_request_id] = service_request.id
        allow(controller).to receive(:initialize_service_request) do
          controller.instance_eval do
            @service_request = ServiceRequest.find_by_id(session[:service_request_id])
          end
          allow(controller.instance_variable_get(:@service_request)).
            to receive_message_chain("protocol.find_sub_service_request_with_ctrc").
            with(service_request.id) { :ssr_id }
        end
        get :protocol, id: service_request.id
      end

      it 'should set @ctrc_services to true' do
        expect(assigns(:ctrc_services)).to be true
      end

      it 'should set @ssr_id to ctrc SubServiceRequest' do
        expect(assigns(:ssr_id)).to eq :ssr_id
      end
    end

    context 'with session[:saved_protocol_id]' do

      build_service_request_with_study

      before(:each) do
        session[:saved_protocol_id] = project.id
        get :protocol, id: service_request.id
      end

      it "should clear the saved protocol in session" do
        expect(session[:saved_protocol_id]).to_not be
      end

      it 'should assign @service_request\'s protocol_id to session[:saved_protocol_id]' do
        expect(assigns(:service_request).protocol_id).to eq project.id
      end
    end

    context "with ServiceRequest belonging to a Study" do

      build_service_request_with_study

      context "with params[:sub_service_request] present" do

        before do
          get :protocol, id: service_request.id, sub_service_request_id: sub_service_request.id
        end

        it "should clear the saved protocol in session" do
          expect(session[:saved_protocol_id]).to eq nil
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end

        it "should set studies to the ServiceRequest's Protocol" do
          expect(assigns[:studies]).to eq [service_request.protocol]
        end

        it "should set projects to empty" do
          expect(assigns[:projects]).to eq []
        end
      end

      context "without params[:sub_service_request]" do

        before do
          get :protocol, id: service_request.id
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end

        it "should set studies to the current Identity's Studies" do
          expect(assigns(:studies).sort).to eq [study, study2].sort
        end

        it "should set projects to the current Identity's Projects ordered by id" do
          expect(assigns(:projects)).to eq jug2.projects(order: :id)
        end
      end
    end

    context "with ServiceRequest belonging to a Project" do

      build_service_request_with_project

      context "with params[:sub_service_request] present" do

        before do
          get :protocol, id: service_request.id, sub_service_request_id: sub_service_request.id
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end

        it "should set studies to empty" do
          expect(assigns[:studies]).to eq []
        end

        it "should set projects to the ServiceRequest's Protocol" do
          expect(assigns[:projects]).to eq [service_request.protocol]
        end
      end

      context "without params[:sub_service_request]" do

        before do
          get :protocol, id: service_request.id
        end

        it "should set service_request" do
          expect(assigns(:service_request)).to eq service_request
        end

        it "should set studies to the current Identity's Studies" do
          expect(assigns(:studies).sort).to eq [study2]
        end

        it "should set projects to the current Identity's Projects ordered by id" do
          expect(assigns(:projects)).to eq jug2.projects(order: :id)
        end
      end
    end
  end
end
