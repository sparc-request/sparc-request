require "spec_helper"

RSpec.describe ClinicalProvider, type: :model do

  describe "#remotely_notify", delay: true do

    context "after_create" do

      it "should create a Delayed::Job" do
        clinical_provider = FactoryGirl.create(:clinical_provider)

        expect(Delayed::Job.where(queue: "remote_service_notifier").count).to eq(1)
      end
    end

    context "around_update" do

      it "should create a Delayed::Job" do
        clinical_provider = FactoryGirl.create(:clinical_provider)
        identity          = FactoryGirl.create(:identity)

        work_off
        clinical_provider.update_attribute(:identity, identity)

        expect(Delayed::Job.where(queue: "remote_service_notifier").count).to eq(1)
      end
    end

    context "after_destroy" do

      it "should create a Delayed::Job" do
        clinical_provider = FactoryGirl.create(:clinical_provider)

        work_off
        clinical_provider.destroy

        expect(Delayed::Job.where(queue: "remote_service_notifier").count).to eq(1)
      end
    end
  end
end
