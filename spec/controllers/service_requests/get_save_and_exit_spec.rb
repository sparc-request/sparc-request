require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j

  describe 'GET save_and_exit' do
    context 'with project' do
      build_service_request_with_project

      shared_examples_for 'always' do
        it 'should redirect the user to the user portal link' do
          get :save_and_exit, id: service_request.id
          expect(response).to redirect_to(DASHBOARD_LINK)
        end
      end

      context 'without params[:sub_service_request_id]' do
        it 'should set the status of the ServiceRequest and associated SubServiceRequests to draft' do
          service_request.update_status('not draft')
          get :save_and_exit, id: service_request.id
          service_request.reload
          expect(service_request.status).to eq 'draft'
          expect(service_request.sub_service_requests).to all(satisfy { |ssr| ssr.status == 'draft' })
        end

        it "should not set the service request's submitted_at to Time.now" do
          time = Time.parse('2012-06-01 12:34:56')
          Timecop.freeze(time) do
            service_request.update_attribute(:submitted_at, nil)
            get :save_and_exit, id: service_request.id
            service_request.reload
            expect(service_request.submitted_at).to eq nil
          end
        end

        it 'should set ssr_id on all associated SubServiceRequests' do
          session[:service_request_id] = service_request.id
          allow(controller).to receive(:initialize_service_request) do
            controller.instance_eval do
              @service_request = ServiceRequest.find_by_id(session[:service_request_id])
              @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
            end
            expect(controller.instance_variable_get(:@service_request)).to receive(:ensure_ssr_ids)
          end
          get :save_and_exit, id: service_request.id
        end

        it 'should should set status of all associated SubServiceRequests to draft' do
          service_request.protocol.update_attribute(:next_ssr_id, 42)

          service_request.sub_service_requests.each(&:destroy)
          ssr1 = create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)
          ssr2 = create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)

          get :save_and_exit, id: service_request.id

          ssr1.reload
          ssr2.reload

          expect(ssr1.status).to eq 'draft'
          expect(ssr2.status).to eq 'draft'
        end

        it 'should create a past status for each SubServiceRequest' do
          service_request.sub_service_requests.each(&:destroy)

          session[:identity_id] = jug2.id

          ssr1 = create(:sub_service_request,
                        service_request_id: service_request.id,
                        status: 'first_draft',
                        organization_id: provider.id)
          ssr2 = create(:sub_service_request,
                        service_request_id: service_request.id,
                        status: 'first_draft',
                        organization_id: core.id)

          xhr :get, :save_and_exit, id: service_request.id

          ps1 = PastStatus.find_by(sub_service_request_id: ssr1.id)
          ps2 = PastStatus.find_by(sub_service_request_id: ssr2.id)

          expect(ps1.status).to eq('first_draft')
          expect(ps2.status).to eq('first_draft')
        end

        it 'should set ssr_id correctly when next_ssr_id > 9999' do
          service_request.protocol.update_attribute(:next_ssr_id, 10_042)

          service_request.sub_service_requests.each(&:destroy)
          ssr1 = create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)

          get :save_and_exit, id: service_request.id

          ssr1.reload
          expect(ssr1.ssr_id).to eq '10042'
        end
      end

    end
  end
end
