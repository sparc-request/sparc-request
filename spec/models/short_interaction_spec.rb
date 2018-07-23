require 'rails_helper'

RSpec.describe ShortInteraction, type: :model do

  it {is_expected.to validate_presence_of(:subject) }

  it {is_expected.to validate_presence_of(:interaction_type) }

  it {is_expected.to validate_presence_of(:duration_in_minutes) }

  it {is_expected.to validate_presence_of(:name) }

  it {is_expected.to validate_presence_of(:email) }

  it {is_expected.to validate_presence_of(:institution) }

  it {is_expected.to validate_presence_of(:note) }

  it { is_expected.to allow_value('email@test.com').for(:email) }

  it { is_expected.not_to allow_value('test').for(:email) }

  it { is_expected.to allow_value('15').for(:duration_in_minutes) }

  it { is_expected.not_to allow_value('test').for(:duration_in_minutes) }
end

