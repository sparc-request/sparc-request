class ContactMailer < ApplicationMailer

  def contact_us_email(contact_form)
    @contact_form = contact_form
    mail(to: 'success@musc.edu', cc: 'sparcrequest@gmail.com', from: "#{contact_form.email}", subject: "#{contact_form.subject}")
  end
end
