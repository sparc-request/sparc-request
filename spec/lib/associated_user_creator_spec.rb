# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require "rails_helper"

RSpec.describe AssociatedUserCreator do
  before :each do
    Delayed::Worker.delay_jobs = false
  end

  after :each do
    Delayed::Worker.delay_jobs = true
  end

  context "params[:project_role] describes a valid ProjectRole" do
    before(:each) do
      @identity = create(:identity)
      @user          = create(:identity)
      @protocol      = create(:protocol_without_validations, selected_for_epic: false, funding_status: 'funded', funding_source: 'federal', type: 'Study')
      create(:project_role, protocol: @protocol, identity: @user, project_rights: 'approve', role: 'primary-pi')
      @sr = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now)
      @ssr = create(:sub_service_request, status: 'not_draft', organization: create(:organization), service_request: @sr, protocol: @protocol)

      @project_role_attrs = { protocol_id: @protocol.id,
        identity_id: @identity.id,
        role: "important",
        project_rights: "to-party" }

    end

    it "#successful? should return true" do
      creator = AssociatedUserCreator.new(@project_role_attrs, @identity)
      expect(creator.successful?).to eq(true)
    end

    it "should create a new ProjectRole for Protocol from params[:project_role][:protocol_id]" do
      expect { AssociatedUserCreator.new(@project_role_attrs, @identity) }.to change { ProjectRole.count }.by(1)
    end

    it "should return new ProjectRole with #protocol_role" do
      creator = AssociatedUserCreator.new(@project_role_attrs, @identity)
      expect(creator.protocol_role).to eq(ProjectRole.last)
    end

    context "send_authorized_user_emails is true and protocol has a previously-submitted SR" do
      it "should send authorized user changed emails" do
        allow(UserMailer).to receive(:authorized_user_changed).twice do
          mailer = double("mailer")
          expect(mailer).to receive(:deliver)
          mailer
        end

        AssociatedUserCreator.new(@project_role_attrs, @identity)
        expect(UserMailer).to have_received(:authorized_user_changed).twice
      end
    end

    context "send_authorized_user_emails is false" do
      stub_config("send_authorized_user_emails", false)
      
      it "should not send authorized user changed emails" do
        @ssr.update_attribute(:status, 'complete')
        allow(UserMailer).to receive(:authorized_user_changed)
        AssociatedUserCreator.new(@project_role_attrs, @identity)

        expect(UserMailer).not_to have_received(:authorized_user_changed)
      end
    end

    context "use_epic is true and Protocol selected for epic is true and queue_epic is false" do
      stub_config("use_epic", true)

      it "should notify for epic user approval" do
        @protocol.update_attribute(:selected_for_epic, true)
        allow(Notifier).to receive(:notify_for_epic_user_approval) do
          mailer = double("mailer")
          expect(mailer).to receive(:deliver)
          mailer
        end

        AssociatedUserCreator.new(@project_role_attrs, @identity)

        expect(Notifier).to have_received(:notify_for_epic_user_approval)
      end
    end
  end

  context "params[:project_role] does not describe a valid ProjectRole" do
    before(:each) do
      protocol = create(:study_without_validations,
        primary_pi: create(:identity),
        selected_for_epic: true)
      identity = create(:identity)
      # missing :role
      @project_role_attrs = { protocol_id: protocol.id,
        identity_id: identity.id,
        project_rights: "to-party" }
    end

    it "#successful? should return false" do
      creator = AssociatedUserCreator.new(@project_role_attrs, @identity)
      expect(creator.successful?).to eq(false)
    end

    it "should not create a new ProjectRole" do
      expect { AssociatedUserCreator.new(@project_role_attrs, @identity) }.not_to change { ProjectRole.count }
    end

    context "send_authorized_user_emails is true" do
      it "should not send authorized user changed emails" do
        allow(UserMailer).to receive(:authorized_user_changed)

        AssociatedUserCreator.new(@project_role_attrs, @identity)

        expect(UserMailer).not_to have_received(:authorized_user_changed)
      end
    end

    context "use_epic is true and Protocol selected for epic is true and queue_epic is false" do
      stub_config("use_epic", true)
      
      it "should not notify for epic user approval" do
        allow(Notifier).to receive(:notify_for_epic_user_approval)

        AssociatedUserCreator.new(@project_role_attrs, @identity)

        expect(Notifier).not_to have_received(:notify_for_epic_user_approval)
      end
    end
  end
end
