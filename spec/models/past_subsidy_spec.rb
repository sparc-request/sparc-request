require 'rails_helper'

RSpec.describe PastSubsidy, type: :model do
  it { is_expected.to belong_to(:sub_service_request) }
  it { is_expected.to belong_to(:approver) }
end
