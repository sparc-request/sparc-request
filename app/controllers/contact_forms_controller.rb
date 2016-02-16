class ContactFormsController < ApplicationController

  def new
    @contact_form = ContactForm.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @contact_form = ContactForm.new(contact_form_params)
    respond_to do |format|
      if @contact_form.valid?
        ContactMailer.contact_us_email(@contact_form).deliver_now
        format.html { head :ok, content_type: 'text/html' }
      else
        format.js { render :new }
      end
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit!
  end
end
