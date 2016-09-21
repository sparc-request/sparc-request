# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class RequestGrantBillingPdf

  def self.text_box_options options
    default_text_box_options = { :height => 10, :overflow => :shrink_to_fit, :min_font_size => 7 }
    default_text_box_options.dup.update options
  end

  def self.generate_pdf(service_request)
    #template_file_name = Rails.root.join('config/pdf_templates/request_grant_billing_template.pdf')
    template_file_name = File.expand_path('../../config/pdf_templates/request_grant_billing_template.pdf', __FILE__)
    pdf = Prawn::Document.new :template => template_file_name
    pdf.font_size = 9
   
    #get data for pdf
    protocol = service_request.protocol
    
    principal_investigators = protocol.project_roles.where(:role => "pi").map{|pr| pr.identity.full_name}.join(", ") 
    billing_business_managers = protocol.project_roles.where(:role => "business-grants-manager").map{|pr| pr.identity.full_name}.join(", ") 

    hr_pro_numbers = ""
    hr_pro_numbers = [protocol.human_subjects_info.hr_number, protocol.human_subjects_info.pro_number].compact.join(", ") if protocol.human_subjects_info
    udak_number = protocol.udak_project_number || ""
    short_title = protocol.short_title

    # question 1
    pdf.text_box principal_investigators, text_box_options(:at => [222, 659], :width => 175)

    # question 2
    pdf.text_box hr_pro_numbers, text_box_options(:at => [280, 636], :width => 100)
    pdf.text_box udak_number, text_box_options(:at => [210, 620], :width => 220)
    pdf.text_box billing_business_managers, text_box_options(:at => [275, 592], :width => 160)

    # question 3
    pdf.text_box short_title, text_box_options(:at => [116, 565], :width => 270)

    # question 4
    case protocol.funding_source_based_on_status  
    when "industry", "investigator"
      pdf.fill_and_stroke_rectangle [118, 539], 5, 6 # funded by Corporate
    when "federal"
      pdf.fill_and_stroke_rectangle [226, 539], 5, 6 # funded by Federal
    else
      pdf.fill_and_stroke_rectangle [334, 539], 5, 6 # funded by Other
      pdf.text_box protocol.display_funding_source_value, text_box_options(:at => [375, 542], :width => 120)
    end
   
    # question 5
    if service_request.sub_service_requests.map(&:ctrc?).any?
      pdf.fill_and_stroke_rectangle [150, 505], 5, 6 # yes
    else
      pdf.fill_and_stroke_rectangle [226, 505], 5, 6 # no
    end
    
    # question 6
    start_date = service_request.protocol.start_date.nil? ? "" : service_request.protocol.start_date.strftime('%m/%d/%Y')
    pdf.text_box start_date, text_box_options(:at => [130, 486])
    
    # question 7
    end_date = service_request.protocol.end_date.nil? ? "" : service_request.protocol.end_date.strftime('%m/%d/%Y')
    pdf.text_box end_date, text_box_options(:at => [125, 463])

    # question 8
    
    # question 9
    subject_count = service_request.arms.map{|arm| arm.subject_count}.sum
    pdf.text_box subject_count.to_s, text_box_options(:at => [192, 415])
    
    # question 10
    # question 11
    # question 12
    
    # question 13
    pdf.text_box billing_business_managers, text_box_options(:at => [48, 279], :width => 335)
    
    # question 14
    
    # question 15, max 58 characters then put it on attached page
    # get only 'required forms' studies
    muha_service_names = service_request.sub_service_requests
                               .select{|x| x.organization.tag_list.include? 'required forms'}
                               .map(&:line_items)
                               .flatten
                               .uniq
                               .map{|line_item| line_item.service.display_service_name}
                               

    muha_service_display = muha_service_names.join(', ').size > 58 ? "See Attached" : muha_service_names.join(', ')
    pdf.text_box muha_service_display, text_box_options(:at => [48, 211], :width => 338)


    # add signatures and submitted_at
    # principal_investigators
    pdf.text_box principal_investigators, text_box_options(:at => [70, 64], :width => 240)
    pdf.text_box service_request.submitted_at.strftime('%m/%d/%Y'), text_box_options(:at => [358, 64])
    
    #billing/business managers
    pdf.text_box billing_business_managers, text_box_options(:at => [70, 21], :width => 240)
    pdf.text_box service_request.submitted_at.strftime('%m/%d/%Y'), text_box_options(:at => [358, 21])

    if muha_service_display == "See Attached" # too long to list on original form
      pdf.start_new_page
      pdf.text "Tests to be included in the study (Question 15)", :size => 14
      pdf.stroke_horizontal_rule
      pdf.move_down 10
      muha_service_names.each do |name|
        pdf.text name
      end
    end

    pdf.render # for testing only, _file File.expand_path('../../tmp/pdfs/xyz.pdf', __FILE__)
  end
end

# uncomment below for testing
# sr = ServiceRequest.find 11704
# RequestGrantBillingPdf.generate_pdf sr
