require 'prawn'

class RequestGrantBillingPdf
  def self.generate_pdf(service_request)
    #template_file_name = Rails.root.join('config/pdf_templates/request_grant_billing_template.pdf')
    template_file_name = '../config/pdf_templates/request_grant_billing_template.pdf'
    pdf = Prawn::Document.new :template => template_file_name
    pdf.font_size = 10
    
    # question 1
    pdf.draw_text "I am the PI", :at => [225, 651]

    # question 2
    pdf.draw_text "Grant Number", :at => [85, 628]
    pdf.draw_text "HR Number", :at => [280, 628]
    pdf.draw_text "Full UDAK", :at => [210, 612]
    pdf.draw_text "Business Manager", :at => [275, 584]

    # question 3
    pdf.draw_text "Andrew's Super Fabulous Study", :at => [116, 558]

    # question 4
    #pdf.fill_and_stroke_rectangle [118, 539], 5, 6 # funded by Corporate
    pdf.fill_and_stroke_rectangle [226, 539], 5, 6 # funded by Federal
    #pdf.fill_and_stroke_rectangle [334, 539], 5, 6 # funded by Other
    #pdf.draw_text "Other Funding Source", :at => [375, 534]
   
    # question 5
    pdf.fill_and_stroke_rectangle [150, 505], 5, 6 # yes
    #pdf.fill_and_stroke_rectangle [226, 505], 5, 6 # no
    
    # question 6
    pdf.draw_text "02/16/2013", :at => [130, 478]
    
    # question 7
    pdf.draw_text "02/16/2019", :at => [125, 455]

    # question 8
    #pdf.draw_text "My house, I guess", :at => [178, 432]

    pdf.render_file '../tmp/pdfs/xyz.pdf'
  end

  def self.attach_to_sub_service_request(sub_service_request)

  end
end

RequestGrantBillingPdf.generate_pdf 'test'
