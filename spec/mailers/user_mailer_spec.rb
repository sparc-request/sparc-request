# Copyright © 2011-2019 MUSC Foundation for Research Development
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

require "rails_helper"

RSpec.describe UserMailer do

  let(:identity)          { create(:identity) }
  let(:modified_identity) { create(:identity) }
  let(:institution)       { create(:institution) }
  let(:provider)          { create(:provider, parent: institution) }
  let(:program)           { create(:program, parent: provider) }
  let(:service)           { create(:service, organization: program) }

  context "added an authorized user" do
    context 'general' do
      before :each do
        @protocol       = create(:study_without_validations, :funded, :federal, primary_pi: identity)
        @sr             = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: @sr, protocol: @protocol, organization: program)
        @li             = create(:line_item, sub_service_request: @ssr, service_request: @sr, service: service)
        @protocol_role  = create(:project_role, protocol: @protocol, identity: modified_identity, project_rights: 'approve', role: 'consultant')
        @mail           = UserMailer.authorized_user_changed(@protocol, identity, [@protocol_role], 'add')
      end

      it 'should display correct subject' do
        expect(@mail).to have_subject("SPARCRequest Authorized Users Update (Protocol #{@protocol.id})")
      end
    
      it "should display the 'added' message" do
        # An Authorized User has been added in SparcDashboard ***(link to protocol)***
        expect(@mail).to have_xpath("//p[normalize-space(text()) = 'An Authorized User has been added in']")
        expect(@mail).to have_xpath "//p//a[@href='http://localhost:0/dashboard/protocols/#{@protocol.id}'][text()= 'SPARCDashboard.']/@href"
      end

      it "should display the Protocol information table" do
        protocol_information_table
      end

      it "should display message conclusion" do
        expect(@mail).to have_xpath("//p[.='Please contact the SUCCESS Center at (843) 792-8300 or success@musc.edu for assistance with this process or with any questions you may have.']")
      end

      it "should display acknowledgments" do
        @protocol.service_requests.first.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
          expect(@mail).to have_xpath("//p[normalize-space(text()) = '#{ack}']")
        end
      end
    end

    context 'when protocol has selected for epic' do
      before :each do
        @protocol       = create(:study_without_validations, :funded, :federal, primary_pi: identity, selected_for_epic: true)
        @sr             = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: @sr, protocol: @protocol, organization: program)
        @li             = create(:line_item, sub_service_request: @ssr, service_request: @sr, service: service)
        @protocol_role  = create(:project_role, protocol: @protocol, identity: modified_identity, project_rights: 'approve', role: 'consultant')
        @mail           = UserMailer.authorized_user_changed(@protocol, identity, [@protocol_role], 'add')
      end

      it 'should show epic column' do
        user_information_table_with_epic_col(true)
      end
    end

    context 'when protocol does not have selected for epic' do
      before :each do
        @protocol       = create(:study_without_validations, :funded, :federal, primary_pi: identity, selected_for_epic: false)
        @sr             = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: @sr, protocol: @protocol, organization: program)
        @li             = create(:line_item, sub_service_request: @ssr, service_request: @sr, service: service)
        @protocol_role  = create(:project_role, protocol: @protocol, identity: modified_identity, project_rights: 'approve', role: 'consultant')
        @mail           = UserMailer.authorized_user_changed(@protocol, identity, [@protocol_role], 'add')
      end

      it 'should not show epic col' do
        user_information_table_without_epic_col(true)
      end
    end
  end

  context "deleted an authorized user" do
    context 'general' do
      before :each do
        @protocol       = create(:study_without_validations, :funded, :federal, primary_pi: identity)
        @sr             = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: @sr, protocol: @protocol, organization: program)
        @li             = create(:line_item, sub_service_request: @ssr, service_request: @sr, service: service)
        @protocol_role  = create(:project_role, protocol: @protocol, identity: modified_identity, project_rights: 'approve', role: 'consultant')
        @mail           = UserMailer.authorized_user_changed(@protocol, identity, [@protocol_role], 'destroy')
      end

      it "should display the 'deleted' message" do
        # An Authorized User has been deleted in SparcDashboard ***(link to protocol)***
        expect(@mail).to have_xpath("//p[normalize-space(text()) = 'An Authorized User has been deleted in']")
        expect(@mail).to have_xpath "//p//a[@href='http://localhost:0/dashboard/protocols/#{@protocol.id}'][text()= 'SPARCDashboard.']/@href"
      end

      it "should display the Protocol information table" do
        protocol_information_table
      end

      it "should display message conclusion" do
        expect(@mail).to have_xpath("//p[.='Please contact the SUCCESS Center at (843) 792-8300 or success@musc.edu for assistance with this process or with any questions you may have.']")
      end

      it "should display acknowledgments" do
        @protocol.service_requests.first.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
          expect(@mail).to have_xpath("//p[normalize-space(text()) = '#{ack}']")
        end
      end
    end

    context 'when protocol has selected for epic' do
      before :each do
        @protocol       = create(:study_without_validations, :funded, :federal, primary_pi: identity, selected_for_epic: true)
        @sr             = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: @sr, protocol: @protocol, organization: program)
        @li             = create(:line_item, sub_service_request: @ssr, service_request: @sr, service: service)
        @protocol_role  = create(:project_role, protocol: @protocol, identity: modified_identity, project_rights: 'approve', role: 'consultant')
        @mail           = UserMailer.authorized_user_changed(@protocol, identity, [@protocol_role], 'destroy')
      end

      it 'should show epic column' do
        user_information_table_with_epic_col(true)
      end
    end

    context 'when protocol does not have selected for epic' do
      before :each do
        @protocol       = create(:study_without_validations, :funded, :federal, primary_pi: identity, selected_for_epic: false)
        @sr             = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: @sr, protocol: @protocol, organization: program)
        @li             = create(:line_item, sub_service_request: @ssr, service_request: @sr, service: service)
        @protocol_role  = create(:project_role, protocol: @protocol, identity: modified_identity, project_rights: 'approve', role: 'consultant')
        @mail           = UserMailer.authorized_user_changed(@protocol, identity, [@protocol_role], 'destroy')
      end

      it 'should not show epic col' do
        user_information_table_without_epic_col(true)
      end
    end
  end
end
