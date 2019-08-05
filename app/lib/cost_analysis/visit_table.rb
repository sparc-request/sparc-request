module CostAnalysis

  class VisitLineItem
    attr_accessor :description, :unit_type, :service_rate, :applicable_rate, :subjects, :visit_counts

    def per_patient_total
      visit_counts.reduce(0.0) do |total, count|
        total + (count * applicable_rate)
      end
    end

    def total_visit_count
      visit_counts.sum
    end

    def per_study_total
      subjects * per_patient_total
    end
  end

  class VisitTable

    # How many columns in the table are static / always there vs the dynamic ones
    # we generate from visits
    DETAIL_TABLE_STATIC_COLUMNS = 5
    SUMMARY_TABLE_STATIC_COLUMNS = 7

    include ActionView::Helpers::NumberHelper

    attr_accessor :arm_name, :line_items, :visit_labels

    def initialize
      @visit_labels = []
      @line_items = {}
    end

    def add_line_item(program_or_core, line_item)
      @line_items[program_or_core] = [] unless @line_items.has_key?(program_or_core)
      @line_items[program_or_core] << line_item
    end

    def cores
      @line_items.keys
    end

    def visit_count
      @visit_labels.size
    end

    def summarized_by_service
      table = TableWithGroupHeaders.new
      table.add_column_labels([
        {:colspan => 2, :content => self.arm_name},
        "Current",
        "Your Price",
        "Qty",
        "Per Patient",
        "Per Study"
      ])
      per_patient_total = 0.0
      per_study_total = 0.0
      cores.each do |core|
        table.add_header(build_program_core_row(core, SUMMARY_TABLE_STATIC_COLUMNS))
        @line_items[core].each do |li|
          per_study_total += li.per_study_total
          per_patient_total += li.per_patient_total
          table.add_data([
            li.description,
            li.unit_type,
            {:content => to_money(li.service_rate), :align => :right},
            {:content => to_money(li.applicable_rate), :align => :right},
            {:content => li.total_visit_count.to_s, :align => :center},
            {:content => to_money(li.per_patient_total), :align => :right},
            {:content => to_money(li.per_study_total), :align => :right}
          ])
        end
      end

      table.add_summary([
        {content: "", colspan: 5},
        {:content => to_money(per_patient_total), :align => :right, :font_style => :bold},
        {:content => to_money(per_study_total), :align => :right, :font_style => :bold}
      ])

      table
    end

    def line_item_detail
      data = TableWithGroupHeaders.new
      data.add_column_labels self.build_header_row
      self.cores.each do |core|
        data.add_header(self.build_program_core_row(core, DETAIL_TABLE_STATIC_COLUMNS + visit_count))

        core_rows = self.build_line_item_rows(@line_items[core])
        data.concat(core_rows)
      end
      data.add_summary self.build_summary_row()
      data
    end


    def build_header_row
      static_columns = [
        {:colspan => 2, :content => self.arm_name, :width => 150},
        {:content => "Current", :size => 5, :width => 40, :align => :center, :valign => :middle},
        {:content => "Your Price",:size => 5, :width => 40, :align => :center, :valign => :middle},
        {:content => "Subject", :width => 40, :align => :center, :valign => :middle, :size => 8}
      ]
      dynamic_columns = @visit_labels.map do |visit_label|
        {
          :content => visit_label,
          :align => :center,
          :single_line => false,
          :overflow => :shrink_to_fit,
          :size => 8
        }
      end

      static_columns + dynamic_columns
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

    def build_line_item_rows(line_items)
      line_items.map do |li|
        label_data = [
          li.description,
          li.unit_type,
          {:content => to_money(li.service_rate), :align => :right},
          {:content => to_money(li.applicable_rate), :align => :right},
          {:content => li.subjects.to_s, :align => :center}
        ]

        visit_data = li.visit_counts.map do |vc|
          {
            :content => vc == 0 ? "" : vc.to_s,
            :align => :center,
            :valign => :middle,
          }
        end
        label_data + visit_data
      end
    end

    def build_summary_row
      summary_column = Array.new(visit_count,0)
      @line_items.each do |program_or_core, lines|
        lines.each do |li|
          li.visit_counts.each_with_index do |count,idx|
            summary_column[idx] += (count * li.applicable_rate)
          end
        end
      end
      static_rows = [{content: "Per Patient", colspan: 5, :align => :right, :font_style => :bold}] 
      dynamic_rows = summary_column.map do |value|
        {:content => to_money(value), :align => :right, :font_style => :bold}
      end

      static_rows + dynamic_rows
    end

    def to_money(v)
      number_with_precision(v, :precision => 2, :delimiter => ",")
    end
  end

end
