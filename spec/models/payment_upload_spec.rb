require 'spec_helper'

describe PaymentUpload do
  it{ should have_attached_file :file }
  it{ should belong_to :payment }
end
