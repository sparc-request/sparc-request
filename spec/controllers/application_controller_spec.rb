# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      initialize_service_request
      render nothing: true
    end

    def show
      prepare_catalog
      render nothing: true
    end

    def not_navigate
      initialize_service_request
      render nothing: true
    end

    def navigate
      initialize_service_request
      render nothing: true
    end
  end

  let_there_be_lane
  let_there_be_j

  describe '#current_user' do
    it 'should call current_identity' do
      expect(controller).to receive(:current_identity)
      controller.send(:current_user)
    end
  end

  describe '#authorize_identity' do
    context 'Identity logged in' do
      before(:each) do
        allow(controller).to receive(:current_user).and_return(jug2)
      end

      context '@sub_service_request nil and Identity can edit @service_request' do
        it 'should authorize Identity' do
          sr = build(:service_request)
          controller.instance_variable_set(:@service_request, sr)
          allow(jug2).to receive(:can_edit_service_request?)
            .with(sr)
            .and_return(true)
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end

      context '@sub_service_request set and Identity can edit @sub_service_request' do
        it 'should authorize Identity' do
          controller.instance_variable_set(:@sub_service_request, :sub_service_request)
          allow(jug2).to receive(:can_edit_sub_service_request?)
            .with(:sub_service_request)
            .and_return(true)
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end

      context '@sub_service_request nil and Identity cannot edit @service_request' do
        it 'should not authorize Identity' do
          sr = build(:service_request)
          controller.instance_variable_set(:@service_request, sr)
          allow(jug2).to receive(:can_edit_service_request?)
            .with(sr)
            .and_return(false)
          expect(controller).to receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end

      context '@sub_service_request set and Identity cannot edit @sub_service_request' do
        it 'should not authorize Identity' do
          controller.instance_variable_set(:@sub_service_request, :sub_service_request)
          allow(jug2).to receive(:can_edit_sub_service_request?)
            .with(:sub_service_request)
            .and_return(false)
          expect(controller).to receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end
    end

    context 'Identity not logged in' do
      before(:each) do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      context 'ServiceRequest in first_draft and not submitted yet' do
        it 'should authorize Identity' do
          service_request = instance_double('ServiceRequest', status: 'first_draft')
          controller.instance_variable_set(:@service_request, service_request)
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end

      context 'ServiceRequest status not first_draft' do
        it 'should authenticate and authorize Identity' do
          service_request = instance_double('ServiceRequest', status: 'draft')
          controller.instance_variable_set(:@service_request, service_request)
          expect(controller).to_not receive(:authorization_error)
          expect(controller).to receive(:authenticate_identity!)
          controller.send(:authorize_identity)
        end
      end

      context 'ServiceRequest and status' do
        it 'should authorize Identity' do
          service_request = instance_double('ServiceRequest', status: 'draft')
          controller.instance_variable_set(:@service_request, service_request)
          expect(controller).to_not receive(:authorization_error)
          expect(controller).to receive(:authenticate_identity!)
          controller.send(:authorize_identity)
        end
      end

      context 'ServiceRequest has nil status' do
        it 'should not authorize Identity' do
          service_request = instance_double('ServiceRequest', status: nil)
          controller.instance_variable_set(:@service_request, service_request)
          expect(controller).to receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end
    end
  end

  describe '#prepare_catalog' do
    build_service_request_with_study

    before(:each) do
      # make Institution list for sub_service_request distinct from
      # list of all Institutions
      create(:institution)
    end

    context 'session[:sub_service_request_id] present and @sub_service_request non-nil' do
      it 'should set @institutions to the @sub_service_request\'s Institutions' do
        session[:sub_service_request_id] = sub_service_request.id
        controller.instance_variable_set(:@sub_service_request, sub_service_request)
        routes.draw { get 'show' => 'anonymous#show' }
        get :show
        expect(assigns(:institutions)).to eq [institution]
      end
    end

    context 'session[:sub_service_request_id] present but @sub_service_request nil' do
      it 'should set @institutions to all Institutions' do
        session[:sub_service_request_id] = sub_service_request.id
        routes.draw { get 'show' => 'anonymous#show' }
        get :show
        expect(assigns(:institutions)).to eq Institution.order('`order`')
      end
    end

    context 'session[:sub_service_request_id] absent but @sub_service_request set' do
      it 'should set @institutions to all Institutions' do
        controller.instance_variable_set(:@sub_service_request, sub_service_request)
        routes.draw { get 'show' => 'anonymous#show' }
        get :show
        expect(assigns(:institutions)).to eq Institution.order('`order`')
      end
    end
  end

  describe '#setup_navigation' do
    build_service_request_with_study

    context 'action is not navigate' do
      before(:each) { session[:service_request_id] = service_request.id }

      it 'should always set @page to params[:action]' do
        routes.draw { get 'not_navigate' => 'anonymous#not_navigate' }
        get :not_navigate, current_location: 'http://www.example.com/something/something/darkside'
        expect(assigns(:page)).to eq 'not_navigate'

        allow(controller.request).to receive(:referrer).and_return('http://www.example.com/foo/bar')
        get :not_navigate
        expect(assigns(:page)).to eq 'not_navigate'
      end
    end

    context 'action is navigate' do
      before(:each) { session[:service_request_id] = service_request.id }

      context 'params[:current_location] present' do
        it 'should assign @page to page referred to by params[:current_location]' do
          routes.draw { get 'navigate' => 'anonymous#navigate' }
          get :navigate, current_location: 'my current location'
          expect(assigns(:page)).to eq 'my current location'
        end
      end

      context 'params[:current_location] absent' do
        it 'should assign @page to page referred to by request referrer' do
          routes.draw { get 'navigate' => 'anonymous#navigate' }
          allow(controller.request).to receive(:referrer).and_return('http://www.example.com/foo/bar')
          get :navigate
          expect(assigns(:page)).to eq 'bar'
        end
      end
    end
  end

  describe '#initialize_service_request' do
    build_service_request_with_study

    context 'not hitting ServiceRequestsController' do
      context 'session[:service_request] absent' do
        it 'should throw an error' do
          expect { get :index }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'session[:service_request_id] present' do
        before(:each) { session[:service_request_id] = service_request.id }

        it 'should set @service_request' do
          get :index
          expect(assigns(:service_request)).to eq service_request
        end

        context 'session[:sub_service_request_id] present' do
          before(:each) do
            session[:sub_service_request_id] = sub_service_request.id
            get :index
          end

          it 'should set @sub_service_request' do
            expect(assigns(:sub_service_request)).to eq sub_service_request
          end

          it "should set @line_items to the SubServiceRequest's LineItems" do
            expect(assigns(:line_items)).to eq sub_service_request.line_items
          end
        end

        context 'session[:sub_service_request_id] absent' do
          before(:each) { get :index }

          it 'should not set @sub_service_request' do
            expect(assigns(:sub_service_request)).to_not be
          end

          it "should set @line_items to the ServiceRequest's LineItems" do
            expect(assigns(:line_items)).to eq service_request.line_items
          end
        end
      end
    end
  end
end
