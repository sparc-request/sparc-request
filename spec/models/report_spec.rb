require 'spec_helper'

describe Report do
  it { should have_attached_file :xlsx }
  it { should belong_to :sub_service_request }
end
