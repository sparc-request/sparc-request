# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class AddHelpContactSettings < ActiveRecord::Migration[5.1]
  def up
    if Setting.find_by_key('contact_us_cc').description.blank?
      Setting.find_by_key('contact_us_cc').update_attribute(:description, 'The email to be CCed when users contact the department for assistance.')
    end

    if Setting.find_by_key('contact_us_cc').friendly_name == 'Contact Us CC'
      Setting.find_by_key('contact_us_cc').update_attribute(:friendly_name, 'Contact us CC')
    end

    if Setting.find_by_key('contact_us_mail_to').description.blank?
      Setting.find_by_key('contact_us_mail_to').update_attribute(:description, 'The email for users to contact the department for assistance.')
    end

    if Setting.find_by_key('contact_us_mail_to').friendly_name == 'Contact Us Mail-To'
      Setting.find_by_key('contact_us_mail_to').update_attribute(:friendly_name, 'Contact us Mail-To')
    end
 
    Setting.create(
      key: 'contact_us_department',
      value: 'SUCCESS Center',
      data_type: 'string',
      friendly_name: 'Contact us Department',
      description: 'The name of the department that users may contact for assistance.'
    )

    Setting.create(
      key: 'contact_us_phone',
      value: '(843) 792-8300',
      data_type: 'string',
      friendly_name: 'Contact us Phone Number',
      description: 'The phone number for users to contact the department for assistance.'
    )
  end

  def down
    Setting.find_by_key('contact_us_department').try(:destroy)
    Setting.find_by_key('contact_us_phone').try(:destroy)
  end
end
