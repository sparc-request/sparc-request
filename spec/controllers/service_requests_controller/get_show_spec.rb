require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  build_one_time_fee_services
  build_per_patient_per_visit_services

  describe 'GET show' do

    context 'without params[:admin_offset]' do

      before(:each) do
        xhr :get, :show, id: service_request.id
      end

      it 'should set protocol' do
        expect(assigns(:protocol)).to eq service_request.protocol
      end

      it 'should not set admin_offset' do
        expect(assigns(:admin_offset)).to_not be
      end
    end

    context 'with params[:admin_offset]' do

      before(:each) do
        xhr :get, :show, id: service_request.id, admin_offset: 10
      end

      it 'should set protocol' do
        expect(assigns(:protocol)).to eq service_request.protocol
      end

      it 'should set admin_offset' do
        expect(assigns(:admin_offset)).to eq '10'
      end
    end
  end
end
