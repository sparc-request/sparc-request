class PaymentUpload < ActiveRecord::Base
  audited
  belongs_to :payment
  has_attached_file :file

  attr_accessible :file, :payment
end
