class Procedure < ActiveRecord::Base
  belongs_to :appointment
  belongs_to :visit
  belongs_to :service
end
