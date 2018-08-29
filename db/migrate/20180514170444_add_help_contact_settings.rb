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
