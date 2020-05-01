# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

  class Arm
    attr_accessor :name, :visit_labels, :line_items
  end

  class ServiceRequest
    def initialize(service_request)
      @service_request = service_request
    end

    def arms
      Enumerator.new do |yielder|
        @service_request.arms.each do |arm|
          ca_arm = CostAnalysis::Arm.new
          ca_arm.name = arm.name
          ca_arm.visit_labels = arm.visit_groups.map { |vg| "#{vg.name}\nDay#{vg.day}" }
          ca_arm.line_items = line_items(arm)

          yielder << ca_arm
        end
      end
    end

    def line_items(arm)
      Enumerator.new do |yielder|
          pppv_line_item_visits(arm).each do |ssr, livs|
            program_or_core = display_org_name_text(livs[0].line_item.service.organization_hierarchy, ssr)
            #This is each line
            livs.each do |liv|

              vli = VisitLineItem.new
              vli.description = liv.line_item.service.display_service_name
              vli.unit_type = display_unit_type(liv)
              vli.service_rate = display_service_rate(liv.line_item)
              vli.applicable_rate = Service.cents_to_dollars(liv.line_item.applicable_rate)
              vli.subjects = liv.subject_count

              vli.visit_counts = eager_loaded_visits(liv).map do |v|
                v.research_billing_qty + v.insurance_billing_qty
              end

              yielder << [program_or_core, vli]
            end
          end
      end
    end

    private

    def pppv_line_item_visits(arm)

      Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(
        arm, 
        @service_request,
        nil,
        merged: true,
        statuses_hidden: nil,
        display_all_services: true)
    end

    def eager_loaded_visits(liv)

      liv.ordered_visits.eager_load(
        line_items_visit: {
          line_item: [
            :admin_rates,
            service_request: :protocol,
            service: [
              :pricing_maps,
              organization: [
                :pricing_setups,
                parent: [
                  :pricing_setups,
                  parent: [
                    :pricing_setups,
                    :parent
                  ]
                ]
              ]
            ]
          ]
        }
      )
    end

    def display_org_name_text(org_name, ssr)
      header  = org_name + (ssr.ssr_id ? " (#{ssr.ssr_id})" : "")
      header
    end

    def display_service_rate line_item
      full_rate = line_item.service.displayed_pricing_map.full_rate
      Service.cents_to_dollars(full_rate)
    end

    def display_unit_type(liv)
      liv.line_item.service.displayed_pricing_map.unit_type.gsub("/", "/ ")
    end
  end
end
