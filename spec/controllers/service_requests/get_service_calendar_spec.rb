# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#service_calendar' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #validate_step' do
      expect(before_filters.include?(:validate_step)).to eq(true)
    end

    it 'should call before_filter #setup_navigation' do
      expect(before_filters.include?(:setup_navigation)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should assign session[:service_calendar_pages] if params[:pages]' do
      org      = create(:organization)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)
      pages    = { arm.id.to_s => '3' }

      xhr :get, :service_calendar, {
        id: sr.id,
        pages: pages
      }

      expect(session[:service_calendar_pages]).to eq(ActionController::Parameters.new(pages))
    end

    context 'does not have line items visits' do
      it 'should create line items visits' do
        org      = create(:organization)
        service  = create(:service, organization: org)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
                   create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:arm, protocol: protocol)

        xhr :get, :service_calendar, {
          id: sr.id
        }

        expect(LineItemsVisit.count).to eq(1)
      end
    end

    context 'has line items visits' do
      context 'subject count changed' do
        it 'should update line items visits subject count' do
          org       = create(:organization)
          service   = create(:service, organization: org)
          protocol  = create(:protocol_federally_funded, primary_pi: logged_in_user)
          sr        = create(:service_request_without_validations, protocol: protocol)
          ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
          line_item = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
          arm       = create(:arm, protocol: protocol, subject_count: 3)
          # This fakes the process of having already gone to the calendar and gone back to service
          # details and updating the arm's subject count
          liv       = build(:line_items_visit, arm: arm, line_item: line_item, subject_count: 5)
          liv.save(validate: false)

          xhr :get, :service_calendar, {
            id: sr.id
          }

          expect(liv.reload.subject_count).to eq(3)
        end
      end

      context 'visit count decreased' do
        it 'should update visit group count' do
          org       = create(:organization)
          service   = create(:service, organization: org)
          protocol  = create(:protocol_federally_funded, primary_pi: logged_in_user)
          sr        = create(:service_request_without_validations, protocol: protocol)
          ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
          line_item = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
          arm       = create(:arm, protocol: protocol, visit_count: 1)
                      create(:line_items_visit, arm: arm, line_item: line_item)
                      create(:visit_group, arm: arm) # Create an extra Visit Group

          xhr :get, :service_calendar, {
            id: sr.id
          }

          expect(arm.visit_groups.count).to eq(1)
        end
      end

      context 'visit count increased' do
        it 'should update visit group count' do
          org       = create(:organization)
          service   = create(:service, organization: org)
          protocol  = create(:protocol_federally_funded, primary_pi: logged_in_user)
          sr        = create(:service_request_without_validations, protocol: protocol)
          ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
          line_item = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
          arm       = create(:arm, protocol: protocol, visit_count: 1)
                      create(:line_items_visit, arm: arm, line_item: line_item)

          arm.update_attribute(:visit_count, 2) # Update Visit Count to force Mass Create Visit Group

          xhr :get, :service_calendar, {
            id: sr.id
          }

          expect(arm.visit_groups.count).to eq(2)
        end
      end
    end

    it 'should render template' do
      org      = create(:organization)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                 create(:arm, protocol: protocol)

      xhr :get, :service_calendar, {
        id: sr.id
      }

      expect(controller).to render_template(:service_calendar)
    end

    it 'should respond ok' do
      org      = create(:organization)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
                 create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                 create(:arm, protocol: protocol)

      xhr :get, :service_calendar, {
        id: sr.id
      }

      expect(controller).to respond_with(:ok)
    end
  end
end
