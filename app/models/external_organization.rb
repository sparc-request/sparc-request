class ExternalOrganization < ApplicationRecord

  audited
  belongs_to :protocol

  attr_accessor :new
  attr_accessor :position
end
