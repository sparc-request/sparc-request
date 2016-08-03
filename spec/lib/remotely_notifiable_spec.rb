# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
require 'rails_helper'

RSpec.describe RemotelyNotifiable, type: :model do

  describe 'callbacks' do

    before do
      @service = build(:service)

      @service.save(validate: false)
    end

    context '#after_create' do

      it 'should add an :after_create callback' do
        expect(@service).to callback(:notify_remote_after_create).after(:create)
      end
    end

    context '#around_update' do

      it 'should add an :around_update callback' do
        expect(@service).to callback(:notify_remote_around_update).around(:update)
      end
    end

    context '#after_destroy' do

      it 'should add an :after_destroy callback' do
        expect(@service).to callback(:notify_remote_after_destroy).after(:destroy)
      end
    end
  end
end
