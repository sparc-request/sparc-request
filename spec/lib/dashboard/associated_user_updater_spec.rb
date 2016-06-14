require "rails_helper"

RSpec.describe Dashboard::AssociatedUserUpdater do
  let!(:primary_pi) { create(:identity) }
  let!(:identity) { create(:identity) }

  context "params[:project_role] describes a valid ProjectRole" do
    it "should update ProjectRole from params[:id] with params[:project_role]" do
      protocol = create(:protocol_without_validations, primary_pi: primary_pi)
      project_role = ProjectRole.create(identity_id: identity.id,
        protocol_id: protocol.id,
        role: "important",
        project_rights: "to-party")

      Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: "not-important" })

      expect(project_role.reload.role).to eq("not-important")
    end
  end

  context "changing role to 'primary-pi'" do
    it "should change current primary pi to a general-access-user" do
      protocol = create(:protocol_without_validations, primary_pi: primary_pi)
      project_role = ProjectRole.create(identity_id: identity.id,
        protocol_id: protocol.id,
        role: "primary-pi",
        project_rights: "to-party")

      Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: "primary-pi" })

      expect(primary_pi.project_roles(0).first.role).to eq("general-access-user")
      expect(project_role.reload.role).to eq("primary-pi")
    end
  end

  context "SEND_AUTHORIZED_USER_EMAILS == true" do
    it "should notify associated users about user change" do
      protocol = create(:protocol_without_validations, primary_pi: primary_pi)
      stub_const("SEND_AUTHORIZED_USER_EMAILS", true)
      project_role = ProjectRole.create(identity_id: identity.id,
        protocol_id: protocol.id,
        role: "important",
        project_rights: "to-party")
      expect(UserMailer).to receive(:authorized_user_changed).with(primary_pi, protocol) do
        mailer_stub = double('mailer')
        expect(mailer_stub).to receive(:deliver)
        mailer_stub
      end
      expect(UserMailer).to receive(:authorized_user_changed).with(identity, protocol) do
        mailer_stub = double('mailer')
        expect(mailer_stub).to receive(:deliver)
        mailer_stub
      end

      Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: "not-important" })
    end
  end

  context "SEND_AUTHORIZED_USER_EMAILS == false" do
    it "should not notify associated users about user change" do
      protocol = create(:protocol_without_validations, primary_pi: primary_pi)
      stub_const("SEND_AUTHORIZED_USER_EMAILS", false)
      project_role = ProjectRole.create(identity_id: identity.id,
        protocol_id: protocol.id,
        role: "important",
        project_rights: "to-party")
      allow(UserMailer).to receive(:authorized_user_changed)

      Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: "not-important" })

      expect(UserMailer).not_to have_received(:authorized_user_changed)
    end
  end

  context "USE_EPIC == true && Protocol selected for epic && QUEUE_EPIC == false" do
    let(:protocol) do
      create(:protocol_without_validations,
        primary_pi: primary_pi,
        selected_for_epic: true)
    end

    before(:each) do
      stub_const("USE_EPIC", true)
      stub_const("QUEUE_EPIC", false)
    end

    context "epic access removed from ProjectRole" do
      it "should deliver a notification regarding epic access removal with updated ProjectRole" do
        project_role = ProjectRole.create(identity_id: identity.id,
          protocol_id: protocol.id,
          role: "important",
          project_rights: "to-party",
          epic_access: true)

        expect(Notifier).to receive(:notify_for_epic_access_removal) do |p, pr|
          # make sure the correct objects are being passed
          expect(p.id).to eq(protocol.id)
          expect(pr.id).to eq(project_role.id)
          expect(pr.epic_access).to eq(false)
          mailer_stub = double('mailer')
          expect(mailer_stub).to receive(:deliver)
          mailer_stub
        end

        Dashboard::AssociatedUserUpdater.new(id: project_role.id,
          project_role: { epic_access: false })
      end
    end

    context "epic access granted to ProjectRole" do
      it "should notify for epic user approval" do
        project_role = ProjectRole.create(identity_id: identity.id,
          protocol_id: protocol.id,
          role: "important",
          project_rights: "to-party",
          epic_access: false)

        expect(Notifier).to receive(:notify_for_epic_user_approval) do |p|
          # make sure the correct objects are being passed
          expect(p.id).to eq(protocol.id)
          mailer_stub = double('mailer')
          expect(mailer_stub).to receive(:deliver)
          mailer_stub
        end

        Dashboard::AssociatedUserUpdater.new(id: project_role.id,
          project_role: { epic_access: true })
      end
    end

    context "ProjectRole's epic rights were changed" do
      it "should notify that epic rights were changed" do
        project_role = ProjectRole.create(identity_id: identity.id,
          protocol_id: protocol.id,
          role: "important",
          project_rights: "to-party",
          epic_access: false)
        project_role.epic_rights.create(right: "left", position: 1)

        expect(Notifier).to receive(:notify_for_epic_rights_changes) do |p, pr, epic_rights|
          # make sure the correct objects are being passed
          expect(p.id).to eq(protocol.id)
          expect(pr.epic_rights.count).to eq(2)
          mailer_stub = double('mailer')
          expect(mailer_stub).to receive(:deliver)
          mailer_stub
        end

        Dashboard::AssociatedUserUpdater.new(id: project_role.id,
          project_role: { epic_rights_attributes: [{ right: "correct", position: 2 }] })
      end
    end
  end

  describe "#protocol_role" do
    it "should return updated ProjectRole, regardless of validity" do
      protocol = create(:protocol_without_validations, primary_pi: primary_pi)
      project_role = ProjectRole.create(identity_id: identity.id,
        protocol_id: protocol.id,
        role: "important",
        project_rights: "to-party")

      updater = Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: nil })

      expect(updater.protocol_role.role).to eq(nil)
    end
  end

  describe "#successful?" do
    let(:protocol) { create(:protocol_without_validations, primary_pi: primary_pi) }

    context "update resulted in invalid ProjectRole" do
      it "should return false" do
        project_role = ProjectRole.create(identity_id: identity.id,
          protocol_id: protocol.id,
          role: "important",
          project_rights: "to-party")

        updater = Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: nil })

        expect(updater.successful?).to eq(false)
      end
    end

    context "update resulted in valid ProjectRole" do
      it "should return true" do
        project_role = ProjectRole.create(identity_id: identity.id,
          protocol_id: protocol.id,
          role: "important",
          project_rights: "to-party")

        updater = Dashboard::AssociatedUserUpdater.new(id: project_role.id, project_role: { role: "not-important" })

        expect(updater.successful?).to eq(true)
      end
    end
  end
end
