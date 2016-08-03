# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
require 'rails_helper'

RSpec.describe PastSubsidy, type: :model do
  it { is_expected.to belong_to(:sub_service_request) }
  it { is_expected.to belong_to(:approver) }
end
