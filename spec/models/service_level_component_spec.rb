require 'spec_helper'

RSpec.describe ServiceLevelComponent, type: :model do

  it { should belong_to(:service).counter_cache(true) }

  it { should validate_presence_of(:component) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:service_id) }

  describe "RemotelyNotifiable", delay: true do

    before { @service_level_component = FactoryGirl.create(:service_level_component) }

    context "after_create" do

      it "should create a DelayedJob" do
        expect(Delayed::Job.count).to eq(1)
      end
    end

    context "around_update" do

      it "should create a DelayedJob" do
        work_off

        @service_level_component.update_attribute :component, "New component"

        expect(Delayed::Job.count).to eq(1)
      end
    end

    context "after_destroy" do

      it "should create a DelayedJob" do
        work_off

        @service_level_component.destroy

        expect(Delayed::Job.count).to eq(1)
      end
    end
  end
end
