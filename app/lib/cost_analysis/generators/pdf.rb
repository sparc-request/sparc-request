module CostAnalysis
  module Generators
    class PDF

      include ActionView::Helpers::NumberHelper

      attr_accessor :study_information, :visit_tables, :otf_tables

      def initialize(doc)
        @doc = doc
        @visit_tables = []
        @otf_tables = []
      end

      def update

        draw do |pdf|
          study_information = @study_information
          primary_investigators = study_information.primary_investigators.map{ |p| ["Primary Investigator", p.name, p.email] }
          additional_contacts = study_information.additional_contacts.map{ |p| [p.role.titleize, p.name, p.email] }
          visit_tables = @visit_tables
          otf_tables = @otf_tables
          grand_total_data = compute_grand_total_data

          pdf.bounding_box([0,pdf.y], :width => 700, :height => 50) do
            pdf.text "CRU Protocol#: #{study_information.protocol_number}", :align => :left, :valign => :center, :size => 16
            pdf.text study_information.enrollment_period, :align => :right, :valign => :top
            study_information.primary_investigators.each do |pi|
              pdf.text pi.name, :align => :right, :valign => :bottom
            end
          end
          pdf.move_down 5
          pdf.stroke_horizontal_rule

          pdf.move_down 30

          pdf.text study_information.short_title
          pdf.move_down 10
          pdf.indent(10) {
            pdf.text study_information.study_title, :style => :italic, :size => 10
          }
          pdf.move_down 10
          pdf.text "Funded by #{study_information.funding_source}"

          pdf.move_down 20

          grand_total_rows = [
            [{ :content => "Study Total", :colspan => 2, :size => 10, :font_style => :bold} ],
            ["Category", "Total Per Study"],
            *grand_total_data[:data_rows].map do |d|
              [
                d[:category],
                { :content => d[:total_as_money], :align => :right }
              ]
            end,
            ["Grand Total", { :content => grand_total_data[:total_as_money], :align => :right, :size => 10, :font_style => :bold }]
          ]

          grand_total_table_style = {
            :border_width => 1,
            :border_color => '4c4c4c',
            :overflow => :shrink_to_fit,
            :size => 8
          }

          grand_total_table = pdf.make_table(
            grand_total_rows,
            :cell_style => grand_total_table_style, :header => true) do
              # Title row
              cells.columns(0..-1).rows(0..1).style({
                :background_color => "91c6d8"
              })
            end

          grand_total_table.draw

          pdf.move_down 20

          #These styles are automatically
          #inherited because they are passed as the cell_style
          #argument
          visit_table_style = {
            :border_width => 1,
            :border_color => '4c4c4c',
            :overflow => :shrink_to_fit,
            :size => 8
          }

          arm_colors = %w( 91c6d8 febc7a 8bcba5 e8aaaf )
          arm_mod = -1

          visit_tables.each do |visit_table|
            arm_mod += 1

            summary_table_data = visit_table.summarized_by_service

            summary_table = pdf.make_table(
              summary_table_data.table_rows,
              :cell_style => visit_table_style, :header => true) do

                # ARM rows
                cells.columns(0..-1).rows(0).style({
                  :background_color => arm_colors[arm_mod % arm_colors.size],
                })
            end

            unless summary_table.cells.fits_on_current_page?(pdf.cursor, pdf.bounds)
              pdf.start_new_page
            end

            summary_table.draw

            pdf.move_down 5

            # Picking the page size that will keep the tables
            # all as close tot he same size as possible
            best_page_size = (8..14).min_by do |size|
              size - (visit_table.visit_count % size)
            end
            #450 is 720 (page width) - 270 (fixed with static columns)
            visit_column_width = 450/best_page_size

            visit_table.line_item_detail.split(keep: VisitTable::DETAIL_TABLE_STATIC_COLUMNS,cols: best_page_size).each do |page|

              detail_table = pdf.make_table(
                page.table_rows,
                :cell_style => visit_table_style, :header => true) do

                  # ARM rows
                  cells.columns(0..-1).rows(0).style({
                    :background_color => arm_colors[arm_mod % arm_colors.size],
                    :single_line => false
                  })

                  cells.columns(VisitTable::DETAIL_TABLE_STATIC_COLUMNS..-1).style({
                    :width => visit_column_width
                  })
                end

                unless detail_table.cells.fits_on_current_page?(pdf.cursor, pdf.bounds)
                  pdf.start_new_page
                end

                detail_table.draw
                pdf.move_down 5
            end
            pdf.move_down 5
          end

          pdf.move_down 20

          otf_table_style = {
            :border_width => 1,
            :border_color => '4c4c4c',
            :overflow => :shrink_to_fit,
            :size => 8
          }

          otf_tables.each do |otf_table|
            summary_table = otf_table.summarized_table

            summary_table = pdf.make_table(
              summary_table.table_rows,
              :cell_style => otf_table_style, :header => true) do
                cells.columns(0..-1).rows(0..1).style({
                  :background_color => "91c6d8",
                })
              end

            unless summary_table.cells.fits_on_current_page?(pdf.cursor, pdf.bounds)
              pdf.start_new_page
            end

            summary_table.draw
          end

          pdf.move_down 20

          investigator_table = pdf.make_table(
            primary_investigators + additional_contacts,
            :width => 700,
            :cell_style => {:border_width => 1, :border_color => 'E8E8E8'})

            pdf.move_down 20

          disclaimer_lines = I18n.t(:disclaimer,scope: [:reporting,:cost_analysis])
          disclaimer_height = disclaimer_lines.map{ |l| 20 }.sum
          fit_table_and_disclaimer = investigator_table.cells.height_with_span + disclaimer_height < (investigator_table.cells[0,0].y + pdf.cursor) - pdf.bounds.absolute_bottom

          unless fit_table_and_disclaimer
            pdf.start_new_page
          end

          investigator_table.draw

          pdf.move_down 20

          pdf.default_leading 3

          pdf.bounding_box([100, pdf.cursor], :width => 500, :height => disclaimer_height, :fill => 'E8E8E8') do
            pdf.transparent(1.0) {
              pdf.stroke_bounds
              pdf.fill_color 'd5edda'
              pdf.fill_rectangle [0,disclaimer_height], 500, disclaimer_height
            }
            pdf.move_down 5
            I18n.t(:disclaimer,scope: [:reporting,:cost_analysis]).each do |line|
              pdf.text line, :size => 11, :align => :center
            end
          end

          pdf.number_pages "<page>", {
            :at => [pdf.bounds.right - 150, pdf.bounds.bottom - 5],
            :width => 150,
            :align => :right,
            :start_count_at => 1,
          }
        end

      end

      private

      def compute_grand_total_data
        grand_total_data = []

        @visit_tables.each do |visit_table|
          summary_table_data = visit_table.summarized_by_service

          table_total = visit_table.cores.sum do |core|
            visit_table.line_items[core].sum do |li|
              li.per_study_total
            end
          end

          grand_total_data << {
            :category => "ARM: #{visit_table.arm_name}",
            :total => table_total,
            :total_as_money => number_with_precision(table_total, :precision => 2, :delimiter => ",")
          }
        end

        @otf_tables.each do |otf_table|
          grand_total_data << {
              :category => "One Time Fees",
              :total => otf_table.total,
              :total_as_money => otf_table.total_as_money
            }
        end

        the_total = grand_total_data.sum { |d| d[:total] }
        the_total_as_money = number_with_precision(the_total, :precision => 2, :delimiter => ",")
        
        {
          :data_rows => grand_total_data,
          :total => the_total,
          :total_as_money => the_total_as_money
        }
      end

      def draw(&block)
        block.call(@doc)
      end

    end
  end
end
