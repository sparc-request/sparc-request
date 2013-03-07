require File.expand_path('../../config/environment', __FILE__)

class RequestGrantBillingPdf
  def self.generate_pdf(service_request)
    #template_file_name = Rails.root.join('config/pdf_templates/request_grant_billing_template.pdf')
    template_file_name = File.expand_path('../../config/pdf_templates/request_grant_billing_template.pdf', __FILE__)
    pdf = Prawn::Document.new :template => template_file_name
    pdf.font_size = 9
   
    #get data for pdf
    protocol = service_request.protocol
    principal_investigators = protocol.project_roles.where(:role => "pi").map{|pr| pr.identity.full_name}.join(", ") 
    billing_business_managers = protocol.project_roles.where(:role => "business-grants-manager").map{|pr| pr.identity.full_name}.join(", ") 
    hr_pro_numbers = [protocol.human_subjects_info.hr_number, protocol.human_subjects_info.pro_number].compact.join(", ")


    # question 1
    pdf.draw_text principal_investigators, :at => [225, 651]

    # question 2
    #pdf.draw_text "Grant Number", :at => [85, 628]
    pdf.draw_text hr_pro_numbers, :at => [280, 628]
    pdf.draw_text protocol.udak_project_number, :at => [210, 612]
    pdf.draw_text "Billing/Business Manager", :at => [275, 584]

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

    pdf.render_file File.expand_path('../../tmp/pdfs/xyz.pdf', __FILE__)
  end
end

sr = ServiceRequest.find 10189
RequestGrantBillingPdf.generate_pdf sr
