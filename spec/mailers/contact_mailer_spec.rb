require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  let!(:contact_form) do
    FactoryGirl.create(:contact_form, subject: 'subject', email: 'example@example.com', message: 'message')
  end

  let(:mail) do
    ContactMailer.contact_us_email(contact_form)
  end

  it 'renders subject' do
    expect(mail.subject).to eq 'subject'
  end

  it 'renders the receiver email' do
    expect(mail.to).to eq(['success@musc.edu'])
  end

  it 'renders the receiver cc email' do
    expect(mail.cc).to eq(['sparcrequest@gmail.com'])
  end

  it 'renders the sender email' do
    expect(mail.from).to eq(['example@example.com'])
  end
end
