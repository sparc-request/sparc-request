module CostAnalysis

    class OftLineItem
        attr_accessor :service_name, :status, :service_rate_dollars, :applicable_rate, :quantity_type, :quantity, :total_dollars_per_study, :unit_type
    end

    class OftTable
        attr_accessor :line_items, :program_or_core

        include ActionView::Helpers::NumberHelper

        def initialize
            @program_or_core = "PROGRAM OR CORE NOT SET"
            @line_items = []
        end

        def add_otf_line_item line_item
            otf_item = CostAnalysis::OftLineItem.new
            otf_item.service_name = line_item.service.display_service_name
            otf_item.status = line_item.status
            otf_item.applicable_rate = Service.cents_to_dollars(line_item.applicable_rate)
            otf_item.service_rate_dollars = Service.cents_to_dollars(line_item.service.displayed_pricing_map.full_rate)
            otf_item.quantity = line_item.quantity
            otf_item.quantity_type = line_item.quantity_type
            otf_item.unit_type = line_item.otf_unit_type
            otf_item.total_dollars_per_study = Service.cents_to_dollars(line_item.service.displayed_pricing_map.full_rate * line_item.quantity)

            line_items << otf_item
        end

        def summarized_table
            col_labels = [
                "Service Name",
                "Status",
                "Service Rate",
                "Your Cost",
                "Unit Type #",
                "Qty Type #",
                "Total Per Study"
            ]
            
            table = TableWithGroupHeaders.new
            table.add_column_labels(title_row("One Time Fees", col_labels.length))
            table.add_column_labels(col_labels)

            table.add_header(build_program_core_row(@program_or_core, col_labels.length))

            @line_items.each do |li|
                table.add_data([
                    li.service_name,
                    li.status,
                    {:content => to_money(li.service_rate_dollars), :align => :right},
                    {:content => to_money(li.applicable_rate), :align => :right},
                    {:content => li.unit_type, :align => :right},
                    {:content => li.quantity_type, :align => :right},
                    to_money(li.total_dollars_per_study)
                ])
            end

            table
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

        def build_program_core_row(program_or_core, colspan)
        [{
            :colspan => colspan,
            :content => program_or_core,
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

    end
end
