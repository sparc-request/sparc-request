require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  before(:each) do
    create(:institution)
    session[:identity_id] = jug2.id
  end

  describe 'GET catalog' do
    it 'should prepare catalog' do
      expect(controller).to receive(:prepare_catalog)
      xhr :get, :catalog, id: service_request.id
    end

    context 'without params[:id]' do
      it 'should delete session[:sub_service_request_id]' do
        session[:sub_service_request_id] = sub_service_request.id
        xhr :get, :catalog
        expect(session[:sub_service_request_id]).to_not be
      end

      context 'with params[:protocol_id]' do
        context 'Identity has permission to create ServiceRequest under Protocol' do
          def do_get
            xhr :get, :catalog, protocol_id: study.id
          end

          it 'should assign a new ServiceRequest to @service_request belonging to specified Protocol' do
            expect { do_get }.to change { ServiceRequest.count }
            expect(assigns(:service_request).protocol_id).to eq study.id
          end

          it 'should set the status of new ServiceRequest to first_draft' do
            do_get
            expect(assigns(:service_request).status).to eq 'first_draft'
          end
        end

        # This scenario appears to throw a DoubleRenderError...
        # context 'Identity does not have permission to create ServiceRequest under Protocol' do
        #   # current_identity does not have permissions for this Protocol:
        #   let(:study2) do
        #     protocol = build(:study)
        #     protocol.update_attributes(funding_status: 'funded', funding_source: 'federal', indirect_cost_rate: 50.0, start_date: Time.now, end_date: Time.now + 2.month)
        #     protocol.save validate: false
        #     identity2 = Identity.find_by_ldap_uid('jpl6@musc.edu')
        #     create(:project_role,
        #       protocol_id:     protocol.id,
        #       identity_id:     identity2.id,
        #       project_rights:  'approve',
        #       role:            'primary-pi')
        #     service_request.update_attribute(:protocol_id, protocol.id)
        #     protocol.reload
        #     protocol
        #   end
        #
        #   def do_get
        #     get :catalog, protocol_id: study2.id
        #   end
        # end
      end

      context 'without params[:protocol_id]' do
        context 'Identity has permission to create ServiceRequest under Protocol' do
          def do_get
            xhr :get, :catalog, protocol_id: study.id
          end

          it 'should assign a new ServiceRequest to @service_request' do
            expect { do_get }.to change { ServiceRequest.count }
            expect(assigns(:service_request)).to be
          end

          it 'should set the status of new ServiceRequest to first_draft' do
            do_get
            expect(assigns(:service_request).status).to eq 'first_draft'
          end
        end
      end
    end

    context 'with params[:id]' do
      it 'should update session[:service_request_id]' do
        session.delete(:service_request_id)
        xhr :get, :catalog, id: service_request.id
        expect(session[:service_request_id]).to eq service_request.id.to_s
      end

      context 'ServiceRequest exists with id params[:id]' do
        it 'should set @service_request' do
          xhr :get, :catalog, id: service_request.id
          expect(assigns[:service_request]).to eq service_request
        end
      end

      context 'ServiceRequest does not exist with id params[:id]' do
      end

      context 'without params[:sub_service_request_id]' do
        it 'should set @institutions to all Institutions' do
          xhr :get, :catalog, id: service_request.id
          expect(assigns(:institutions)).to eq Institution.all.sort_by { |i| i.order.to_i }
        end
      end

      context 'with params[:sub_service_request_id]' do
        it "should set @instutitions to the SubServiceRequest's Institution" do
          xhr :get, :catalog, id: service_request.id, sub_service_request_id: sub_service_request.id
          expect(assigns(:institutions)).to eq [institution]
        end

        it 'should update session[:sub_service_request_id]' do
          session.delete(:sub_service_request_id)
          xhr :get, :catalog, id: service_request.id, sub_service_request_id: sub_service_request.id
          expect(session[:sub_service_request_id]).to eq sub_service_request.id.to_s
        end
      end
    end

    # TODO: Try and figure out a clean way of setting up the test config to be able to
    #       test locked organization checks and finding the ctrc ssr id
  end
end
