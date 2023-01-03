# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

module CostAnalysis
  class Generator
    attr_writer :protocol

    def to_pdf(doc)
      pdf = CostAnalysis::Generators::PDF.new(doc)
      pdf.study_information = CostAnalysis::StudyInformation.new(@protocol)

      @protocol.service_requests.each do |sr|
        service_request = CostAnalysis::ServiceRequest.new(sr)

        service_request.arms.each do |arm|
          pdf.visit_tables << build_visit_table(arm)
        end

        pdf.otf_tables << build_otf_table(service_request)

      end

      pdf.setup_render
    end

    def build_visit_table(arm)
      table = CostAnalysis::VisitTable.new
      table.arm_name = arm.name
      table.visit_labels = arm.visit_labels
      arm.line_items.each do |core, line_item|
        table.add_line_item core, line_item
      end

      table
    end

    def build_otf_table(service_request)
      sub_srv_reqs = service_request.otf_line_items()

      tbl = CostAnalysis::OtfTable.new

      sub_srv_reqs.each do |ssr_with_lis|
          ssr = ssr_with_lis[0]
          lis = ssr_with_lis[1]

          lis.each do |li|
              tbl.add_otf_line_item(li)
          end

      end

      tbl
    end

    def preview(thing)
      case thing
      when :pdf
        pdf = Prawn::Document.new(:page_layout => :landscape)
        to_pdf(pdf)
        pdf.render_file("preview.pdf")
        `open preview.pdf`
      end
    end

    def preview_pdf_named(file_name = "tmp/pdfs/preview.pdf")
      pdf = Prawn::Document.new(:page_layout => :landscape)
      to_pdf(pdf)
      pdf.render_file(file_name)
    end
  end
end
