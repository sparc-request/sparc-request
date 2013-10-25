require 'spec_helper'

describe CoverLetter do
  it{ should belong_to :sub_service_request }
  it{ should validate_presence_of :content }
end
