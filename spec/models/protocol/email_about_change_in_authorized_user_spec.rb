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
require 'date'
require 'rails_helper'

RSpec.describe Protocol, type: :model do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study()
  build_service_request_with_project()
  build_study_type_question_groups()
  build_study_type_questions()
  build_study_type_answers()

  describe "#email_about_change_in_authorized_user" do
    context "SEND_AUTHORIZED_USER_EMAILS == true && ssr.status == 'not_draft'" do
      it "should send authorized user email" do
        stub_const('SEND_AUTHORIZED_USER_EMAILS', true)
        organization = create(:organization)
        @protocol1 = create(:study_without_validations)
        @sr1 = create(:service_request_without_validations, protocol_id: @protocol1.id)
        @ssr1 = create(:sub_service_request_without_validations, service_request_id: @sr1.id, organization: organization, status: 'not_draft', protocol: @protocol1)
        create(:project_role_with_identity, protocol: @protocol1)
        modified_role = create(:project_role_with_identity, protocol: @protocol1)

        allow(UserMailer).to receive(:authorized_user_changed).twice do
          mailer = double("mailer")
          expect(mailer).to receive(:deliver)
          mailer
        end

        @protocol1.email_about_change_in_authorized_user(modified_role, 'destroy')
        expect(UserMailer).to have_received(:authorized_user_changed).twice
      end
    end

    context "SEND_AUTHORIZED_USER_EMAILS == true && ssr.status == 'draft'" do
      it "should send authorized user email" do
        stub_const('SEND_AUTHORIZED_USER_EMAILS', true)
        organization = create(:organization)
        @protocol1 = create(:study_without_validations)
        @sr1 = create(:service_request_without_validations, protocol_id: @protocol1.id)
        @ssr1 = create(:sub_service_request_without_validations, service_request_id: @sr1.id, organization: organization, status: 'draft', protocol: @protocol1)
        create(:project_role_with_identity, protocol: @protocol1)
        modified_role = create(:project_role_with_identity, protocol: @protocol1)

        allow(UserMailer).to receive(:authorized_user_changed) do
          mailer = double()
          expect(mailer).not_to receive(:deliver)
          mailer
        end

        @protocol1.email_about_change_in_authorized_user(modified_role, 'destroy')
        expect(UserMailer).not_to have_received(:authorized_user_changed)
      end
    end

    context "SEND_AUTHORIZED_USER_EMAILS == false && ssr.status == 'draft'" do
      it "should send authorized user email" do
        stub_const('SEND_AUTHORIZED_USER_EMAILS', false)
        organization = create(:organization)
        @protocol1 = create(:study_without_validations)
        @sr1 = create(:service_request_without_validations, protocol_id: @protocol1.id)
        @ssr1 = create(:sub_service_request_without_validations, service_request_id: @sr1.id, organization: organization, status: 'draft', protocol: @protocol1)
        create(:project_role_with_identity, protocol: @protocol1)
        modified_role = create(:project_role_with_identity, protocol: @protocol1)

        allow(UserMailer).to receive(:authorized_user_changed) do
          mailer = double()
          expect(mailer).not_to receive(:deliver)
          mailer
        end

        @protocol1.email_about_change_in_authorized_user(modified_role, 'destroy')
        expect(UserMailer).not_to have_received(:authorized_user_changed)
      end
    end

    context "SEND_AUTHORIZED_USER_EMAILS == false && ssr.status == 'not_draft'" do
      it "should send authorized user email" do
        stub_const('SEND_AUTHORIZED_USER_EMAILS', false)
        organization = create(:organization)
        @protocol1 = create(:study_without_validations)
        @sr1 = create(:service_request_without_validations, protocol_id: @protocol1.id)
        @ssr1 = create(:sub_service_request_without_validations, service_request_id: @sr1.id, organization: organization, status: 'not_draft', protocol: @protocol1)
        create(:project_role_with_identity, protocol: @protocol1)
        modified_role = create(:project_role_with_identity, protocol: @protocol1)

        allow(UserMailer).to receive(:authorized_user_changed) do
          mailer = double()
          expect(mailer).not_to receive(:deliver)
          mailer
        end

        @protocol1.email_about_change_in_authorized_user(modified_role, 'destroy')
        expect(UserMailer).not_to have_received(:authorized_user_changed)
      end
    end
  end
end
