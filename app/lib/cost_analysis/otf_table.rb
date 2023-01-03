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

    class OtfLineItem
        attr_accessor :service_name, :status, :service_rate_dollars, :applicable_rate,
            :quantity_type, :quantity, :unit_type, :units_per_quantity,
            :total_dollars_per_study, :program_or_core
    end

    class OtfTable
        HEADER_LABEL = "Non-clinical Services"

        attr_accessor :line_items

        include ActionView::Helpers::NumberHelper

        def initialize
            @line_items = {}
        end

        def add_otf_line_item(line_item)
            otf_item = CostAnalysis::OtfLineItem.new
            otf_item.service_name = line_item.service.display_service_name
            otf_item.status = line_item.status
            otf_item.applicable_rate = Service.cents_to_dollars(line_item.applicable_rate)
            otf_item.service_rate_dollars = Service.cents_to_dollars(line_item.service.displayed_pricing_map.full_rate)
            otf_item.quantity = line_item.quantity
            otf_item.quantity_type = line_item.quantity_type
            otf_item.unit_type = line_item.otf_unit_type
            otf_item.units_per_quantity = line_item.units_per_quantity
            otf_item.total_dollars_per_study = Service.cents_to_dollars(line_item.applicable_rate * line_item.quantity)
            otf_item.program_or_core = line_item.service.organization_hierarchy

            ssr_id = line_item.sub_service_request.ssr_id

            @line_items[ssr_id] = [] unless @line_items.has_key?(ssr_id)
            @line_items[ssr_id] << otf_item
        end

        def get_col_labels
            [
                "Service Name",
                "Status",
                "Service Rate",
                "Your Cost",
                "Qty",
                "Qty Type",
                "Units per Qty",
                "Unit Type",
                "Total Per Study"
            ]
        end

        def summarized_table
            col_labels = get_col_labels
            
            table = TableWithGroupHeaders.new
            table.add_column_labels(title_row(HEADER_LABEL, col_labels.length))
            table.add_column_labels(col_labels)

            ssr_ids.each do |ssr_id|
                table.add_header(build_ssr_header_row(@line_items[ssr_id][0].program_or_core, ssr_id, col_labels.length))

                @line_items[ssr_id].sort_by() { |li| li.service_name }.each do |li|
                    table.add_data([
                        li.service_name,
                        li.status,
                        {:content => to_money(li.service_rate_dollars), :align => :right},
                        {:content => to_money(li.applicable_rate), :align => :right},
                        {:content => li.quantity.to_s, :align => :right},
                        {:content => li.quantity_type, :align => :right},
                        {:content => li.units_per_quantity.to_s, :align => :right},
                        {:content => li.unit_type, :align => :right},
                        {:content => to_money(li.total_dollars_per_study), :align => :right}
                    ])
                end

            end

            table.add_data(total_row)

            table
        end

        def ssr_header_text(org_name, ssr_id)
            "#{org_name} (#{ssr_id})"
        end

        def title_row(text, colspan)
            [{
                :colspan => colspan,
                :content => text,
                :align => :left,
                :valign => :middle,
                :background_color => 'E8E8E8',
                :size => 10,
                :font_style => :bold
            }]
        end

        def total_row
            [
                {:colspan => get_col_labels.length - 1, :content => ''},
                {:content => total_as_money, :align => :right, :font_style => :bold}
            ]
        end

        def build_ssr_header_row(program_or_core, ssr_id, colspan)
            ssr_header_text = "#{program_or_core} (#{ssr_id})"
            [{
                :colspan => colspan,
                :content => ssr_header_text,
                :align => :left,
                :valign => :middle,
                :background_color => 'E8E8E8',
                :size => 10,
                :font_style => :bold
            }]
        end

        def to_money(v)
            number_with_precision(v, :precision => 2, :delimiter => ",")
        end

        def total
            @line_items.sum { |g| total_by_ssr_id(g[0]) }
        end

        def total_as_money
            to_money(total)
        end

        def total_by_ssr_id(ssr_id)
            @line_items[ssr_id].sum { |li| li.total_dollars_per_study }
        end

        def ssr_ids
            @line_items.keys.sort
        end

    end
end
