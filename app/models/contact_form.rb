# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class ContactForm < ActiveRecord::Base
  validates :email,
            :message,
            presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end
