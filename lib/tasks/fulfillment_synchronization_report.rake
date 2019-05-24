# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

desc "Generate a Report showing inconsistent data between SPARCRequest and SPARCFulfillment that needs to be synchronized"
namespace :report do
  task fulfillment_synchronization: :environment do
    Axlsx::Package.new do |p|
      wb = p.workbook

      @default        = wb.styles.add_style sz: 12, alignment: { horizontal: :left }
      @b              = wb.styles.add_style sz: 12, b: true, alignment: { horizontal: :left }
      @c              = wb.styles.add_style sz: 12, alignment: { horizontal: :center }
      @bc             = wb.styles.add_style sz: 12, b: true, alignment: { horizontal: :center }
      @header         = wb.styles.add_style sz: 24, b: true, bg_color: '227BA4', fg_color: 'FFFFFF', alignment: { horizontal: :left }
      @section_header = wb.styles.add_style sz: 20, b: true, bg_color: '888888', fg_color: 'FFFFFF', alignment: { horizontal: :left }
      @sub_header     = wb.styles.add_style sz: 16, bg_color: 'CCCCCCC', border: { style: :thin, color: '000000' }, alignment: { horizontal: :center }
      @data_error     = wb.styles.add_style sz: 16, b: true, bg_color: 'C43149', fg_color: 'FFFFFF', alignment: { horizontal: :center }

      def sparc_arm_styles(sparc_arm)
        styles  = [@bc]
        styles << (sparc_arm.fulfillment_arms.any? && sparc_arm.fulfillment_arms.where.not(name: sparc_arm.name).any?                   ? @data_error : @b)
        styles << (sparc_arm.fulfillment_arms.any? && sparc_arm.fulfillment_arms.where.not(subject_count: sparc_arm.subject_count).any? ? @data_error : @c)
        styles << (sparc_arm.fulfillment_arms.any? && sparc_arm.fulfillment_arms.where.not(visit_count: sparc_arm.visit_count).any?     ? @data_error : @c)
        styles += [@default, @default, @default]
        styles
      end

      def cwf_arm_styles(cwf_arm)
        styles  = [@default, @bc]
        styles << (cwf_arm.sparc_arm && cwf_arm.name          != cwf_arm.sparc_arm.try(:name)          ? @data_error : @b)
        styles << (cwf_arm.sparc_arm && cwf_arm.subject_count != cwf_arm.sparc_arm.try(:subject_count) ? @data_error : @c)
        styles << (cwf_arm.sparc_arm && cwf_arm.visit_count   != cwf_arm.sparc_arm.try(:visit_count)   ? @data_error : @c)
        styles += [@default, @default, @default]
        styles
      end

      def sparc_li_styles(sparc_liv, sparc_li)
        styles  = [@bc, @bc, @b]
        styles << (sparc_li.fulfillment_line_items.any? && sparc_li.fulfillment_line_items.where.not(subject_count: sparc_liv.subject_count).any? ? @data_error : @c)
        styles += [@default, @default, @default]
        styles
      end

      def cwf_li_styles(cwf_li, sparc_liv)
        styles  = [@default, @bc, @bc, @b]
        styles << (sparc_liv && cwf_li.subject_count != sparc_liv.try(:subject_count) ? @data_error : @c)
        styles += [@default, @default, @default]
        styles
      end

      def sparc_vg_styles(sparc_vg)
        styles  = [@bc, @bc]
        styles << (sparc_vg.fulfillment_visit_groups.any? && sparc_vg.fulfillment_visit_groups.where.not(name: sparc_vg.name).any?                   ? @data_error : @bc)
        styles << (sparc_vg.fulfillment_visit_groups.any? && sparc_vg.fulfillment_visit_groups.where.not(position: sparc_vg.position).any?           ? @data_error : @c)
        styles << (sparc_vg.fulfillment_visit_groups.any? && sparc_vg.fulfillment_visit_groups.where.not(window_before: sparc_vg.window_before).any? ? @data_error : @c)
        styles << (sparc_vg.fulfillment_visit_groups.any? && sparc_vg.fulfillment_visit_groups.where.not(day: sparc_vg.day).any?                     ? @data_error : @c)
        styles << (sparc_vg.fulfillment_visit_groups.any? && sparc_vg.fulfillment_visit_groups.where.not(window_after: sparc_vg.window_after).any?   ? @data_error : @c)
        styles
      end

      def cwf_vg_styles(cwf_vg)
        styles  = [@default, @bc, @bc]
        styles << (cwf_vg.sparc_visit_group && cwf_vg.name           != cwf_vg.sparc_visit_group.try(:name)           ? @data_error : @b)
        styles << (cwf_vg.sparc_visit_group && cwf_vg.position       != cwf_vg.sparc_visit_group.try(:position)       ? @data_error : @c)
        styles << (cwf_vg.sparc_visit_group && cwf_vg.window_before  != cwf_vg.sparc_visit_group.try(:window_before)  ? @data_error : @c)
        styles << (cwf_vg.sparc_visit_group && cwf_vg.day            != cwf_vg.sparc_visit_group.try(:day)            ? @data_error : @c)
        styles << (cwf_vg.sparc_visit_group && cwf_vg.window_after   != cwf_vg.sparc_visit_group.try(:window_after)   ? @data_error : @c)
        styles
      end

      def sparc_visit_styles(sparc_visit)
        styles  = [@bc, @bc, @bc, @bc]
        styles << (sparc_visit.fulfillment_visits.any? && sparc_visit.fulfillment_visits.where.not(research_billing_qty: sparc_visit.research_billing_qty).any?   ? @data_error : @c)
        styles << (sparc_visit.fulfillment_visits.any? && sparc_visit.fulfillment_visits.where.not(insurance_billing_qty: sparc_visit.insurance_billing_qty).any? ? @data_error : @c)
        styles << (sparc_visit.fulfillment_visits.any? && sparc_visit.fulfillment_visits.where.not(effort_billing_qty: sparc_visit.effort_billing_qty).any?       ? @data_error : @c)
        styles
      end

      def cwf_visit_styles(cwf_visit)
        styles  = [@default, @bc, @bc, @bc, @bc]
        styles << (cwf_visit.sparc_visit && cwf_visit.research_billing_qty  != cwf_visit.sparc_visit.try(:research_billing_qty)  ? @data_error : @c)
        styles << (cwf_visit.sparc_visit && cwf_visit.insurance_billing_qty != cwf_visit.sparc_visit.try(:insurance_billing_qty) ? @data_error : @c)
        styles << (cwf_visit.sparc_visit && cwf_visit.effort_billing_qty    != cwf_visit.sparc_visit.try(:effort_billing_qty)    ? @data_error : @c)
        styles
      end

      Protocol.includes(:arms, :sub_service_requests).where(sub_service_requests: { in_work_fulfillment: true }).distinct.order(:id).to_a.each_slice(100).each do |sparc_protocols|
        wb.add_worksheet(name: "#{sparc_protocols.first.id} to #{sparc_protocols.last.id}") do |sheet|
          sparc_protocols.each do |sparc_protocol|
            header_row              = ["SPARC Protocol #{sparc_protocol.id}", "", "", "", "", "", ""]
            header_styles           = [@header] * 7

            arm_header_row          = ["Arms", "", "", "", "", "", ""]
            arm_sub_header_row      = ["ID", "Name", "Subject Count", "Visit Count", "", "", ""]
            arm_header_styles       = [@section_header] * 7
            arm_sub_header_styles   = [@sub_header] * 7

            li_header_row           = ["Line Items", "", "", "", "", "", ""]
            li_sub_header_row       = ["Line Item ID / Line Items Visit ID", "Arm ID / Name", "Service", "Subject Count", "", "", ""]
            li_header_styles        = [@section_header] * 7
            li_sub_header_styles    = [@sub_header] * 7

            vg_header_row           = ["Visit Groups", "", "", "", "", "", ""]
            vg_sub_header_row       = ["ID", "Arm ID / Name", "Name", "Position", "Window Before", "Day", "Window After"]
            vg_header_styles        = [@section_header] * 7
            vg_sub_header_styles    = [@sub_header] * 7

            visit_header_row        = ["Visits", "", "", "", "", "", ""]
            visit_sub_header_row    = ["ID", "Arm ID / Name", "Line Item ID / Line Items Visit ID / Service", "Visit Group ID/Name", "R", "T", "%"]
            visit_header_styles     = [@section_header] * 7
            visit_sub_header_styles = [@sub_header] * 7

            if sparc_protocol.fulfillment_protocols.with_pppv_services.any?
              ###############
              # HEADER ROWS #
              ###############

              sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                if cwf_protocol.sparc_sub_service_request
                  header_row              += ["", "CWF Protocol #{cwf_protocol.sparc_sub_service_request.display_id}", "", "", "", "", "", ""]
                  header_styles           += [@default] + ([@header] * 7)

                  arm_header_row          += ["", "Arms", "", "", "", "", "", ""]
                  arm_sub_header_row      += ["", "ID / SPARC ID", "Name", "Subject Count", "Visit Count", "", "", ""]
                  arm_header_styles       += [@default] + ([@section_header] * 7)
                  arm_sub_header_styles   += [@default] + ([@sub_header] * 7)

                  li_header_row           += ["", "Line Items", "", "", "", "", "", ""]
                  li_sub_header_row       += ["", "ID / SPARC ID", "Arm ID / Name", "Service", "Subject Count", "", "", ""]
                  li_header_styles        += [@default] + ([@section_header] * 7)
                  li_sub_header_styles    += [@default] + ([@sub_header] * 7)

                  vg_header_row           += ["", "Visit Groups", "", "", "", "", "", ""]
                  vg_sub_header_row       += ["", "ID / SPARC ID", "Arm ID / Name", "Name", "Position", "Window Before", "Day", "Window After"]
                  vg_header_styles        += [@default] + ([@section_header] * 7)
                  vg_sub_header_styles    += [@default] + ([@sub_header] * 7)

                  visit_header_row        += ["", "Visits", "", "", "", "", "", ""]
                  visit_sub_header_row    += ["", "ID / SPARC ID", "Arm ID / Name", "Line Item ID / SPARC ID / Service", "Visit Group ID / Name", "R", "T", "%"]
                  visit_header_styles     += [@default] + ([@section_header] * 7)
                  visit_sub_header_styles += [@default] + ([@sub_header] * 7)
                else
                  header_row              += ["", "CWF Protocol #{cwf_protocol.id} (Sub Service Request Missing)", "", "", "", "", "", ""]
                  header_styles           += [@default] + ([@data_error] * 7)

                  arm_header_row          += ["", "Arms", "", "", "", "", "", ""]
                  arm_sub_header_row      += ["", "ID / SPARC ID", "Name", "Subject Count", "Visit Count", "", "", ""]
                  arm_header_styles       += [@default] + ([@section_header] * 7)
                  arm_sub_header_styles   += [@default] + ([@sub_header] * 7)

                  li_header_row           += ["", "Line Items", "", "", "", "", "", ""]
                  li_sub_header_row       += ["", "ID / SPARC ID", "Arm ID / Name", "Service", "Subject Count", "", "", "", ""]
                  li_header_styles        += [@default] + ([@section_header] * 7)
                  li_sub_header_styles    += [@default] + ([@sub_header] * 7)

                  vg_header_row           += ["", "Visit Groups", "", "", "", "", "", ""]
                  vg_sub_header_row       += ["", "ID / SPARC ID", "Arm ID / Name", "Name", "Position", "Window Before", "Day", "Window After"]
                  vg_header_styles        += [@default] + ([@section_header] * 7)
                  vg_sub_header_styles    += [@default] + ([@sub_header] * 7)

                  visit_header_row        += ["", "Visits", "", "", "", "", "", ""]
                  visit_sub_header_row    += ["", "ID / SPARC ID", "Arm ID / Name", "Line Item ID / SPARC ID / Service", "Visit Group ID / Name", "R", "T", "%", ""]
                  visit_header_styles     += [@default] + ([@section_header] * 7)
                  visit_sub_header_styles += [@default] + ([@sub_header] * 7)
                end
              end

              # Index [0] are records present in SPARCRequest and SPARCFulfillment
              # Index [1] are records present only in SPARCRequest with no record of it having existed in SPARCFulfillment
              # Index [2] are records present only in SPARCFulfillment with no record of it having existed in SPARCRequest via the Audit Trail
              arm_rows      = [[], [], []]
              arm_styles    = [[], [], []]
              liv_rows      = [[], [], []]
              liv_styles    = [[], [], []]
              vg_rows       = [[], [], []]
              vg_styles     = [[], [], []]
              visit_rows    = [[], [], []]
              visit_styles  = [[], [], []]

              ########
              # ARMS #
              ########
              ### Get all arms in SPARC with corresponding Fulfillment Arms
              ### Get all remaining SPARC Arms without corresponding Fulfillment Arms
              ### Get all remaining Fulfillment Arms without corresponding SPARC Arms

              sparc_arms = sparc_protocol.arms.includes(:fulfillment_arms).select do |sparc_arm|
                sparc_arm.fulfillment_arms.where.not(name: sparc_arm.name)
                  .or(sparc_arm.fulfillment_arms.where.not(subject_count: sparc_arm.subject_count))
                  .or(sparc_arm.fulfillment_arms.where.not(visit_count: sparc_arm.visit_count))
                  .or(sparc_arm.fulfillment_arms.deleted)
                  .any?
              end

              sparc_arms.each do |sparc_arm|
                row     = [sparc_arm.id, sparc_arm.name, sparc_arm.subject_count, sparc_arm.visit_count, "", "", ""]
                styles  = sparc_arm_styles(sparc_arm)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_arm = sparc_arm.fulfillment_arms.detect{ |cwf_arm| cwf_arm.protocol_id == cwf_protocol.id }
                    # The SPARC record is present for the protocol
                    if cwf_arm.deleted_at.nil?
                      # The record was not deleted
                      row    += ["", "#{cwf_arm.id} / #{cwf_arm.sparc_id}", cwf_arm.name, cwf_arm.subject_count, cwf_arm.visit_count, "", "", ""]
                      styles += cwf_arm_styles(cwf_arm)
                    else
                      # The record was deleted
                      row    += ["", "Arm Deleted", "", "", "", "", "", ""]
                      styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                    end
                  else
                    # The SPARC record is missing for the protocol
                    row    += ["", "Arm Missing", "", "", "", "", "", ""]
                    styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                  end
                end

                arm_rows[0]   << row
                arm_styles[0] << styles
              end

              sparc_protocol.arms.select{ |sparc_arm| sparc_arm.fulfillment_arms.empty? }.each do |sparc_arm|
                row     = [sparc_arm.id, sparc_arm.name, sparc_arm.subject_count, sparc_arm.visit_count, "", "", ""]
                styles  = sparc_arm_styles(sparc_arm)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  row    += ["", "Arm Missing", "", "", "", "", "", ""]
                  styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                arm_rows[1]   << row
                arm_styles[1] << styles
              end

              Shard::Fulfillment::Arm.where(protocol: sparc_protocol.fulfillment_protocols.with_pppv_services).select{ |cwf_arm| cwf_arm.sparc_arm.nil? rescue true }.each do |cwf_arm|
                if AuditRecovery.where(auditable_type: 'Arm', auditable_id: cwf_arm.sparc_id, action: 'destroy')
                  # The record was deleted in SPARCRequest
                  row     = ["Arm Deleted", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                else
                  # There was never a record in SPARCRequest or the data is corrupted
                  row     = ["Arm Missing", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_arm.protocol_id == cwf_protocol.id
                    row    += ["", "#{cwf_arm.id} / #{cwf_arm.sparc_id || 'NULL'}", cwf_arm.name, cwf_arm.subject_count, cwf_arm.visit_count, "", "", ""]
                    styles += cwf_arm_styles(cwf_arm)
                  else
                    row    += ["", "", "", "", "", "", "", ""]
                    styles += [@default, @default, @default, @default, @default, @default, @default, @default]
                  end
                end

                arm_rows[2]   << row
                arm_styles[2] << styles
              end

              ##############
              # LINE ITEMS #
              ##############
              ### Get all Line Items in SPARC with corresponding Fulfillment Line Items
              ### Get all remaining SPARC Line Items without corresponding Fulfillment Line Items
              ### Get all remaining Fulfillment Line Items without corresponding SPARC Line Items

              sparc_livs = sparc_protocol.line_items_visits.includes(:arm, :sub_service_request, line_item: :fulfillment_line_items).select do |sparc_liv|
                sparc_liv.sub_service_request.in_work_fulfillment && 
                  sparc_liv.line_item.fulfillment_line_items.includes(:arm).where(arms: { sparc_id: sparc_liv.arm_id }).where.not(subject_count: sparc_liv.subject_count)
                  .or(sparc_liv.line_item.fulfillment_line_items.includes(:arm).deleted)
                  .any?
              end

              sparc_livs.each do |sparc_liv|
                sparc_li  = sparc_liv.line_item
                row       = ["#{sparc_li.id} / #{sparc_liv.id}", "#{sparc_liv.arm.id} / #{sparc_liv.arm.name}", sparc_liv.service.abbreviation, sparc_liv.subject_count, "", "", ""]
                styles    = sparc_li_styles(sparc_liv, sparc_li)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_li = sparc_li.fulfillment_line_items.includes(:arm).detect{ |cwf_li| cwf_li.arm.try(:sparc_id) == sparc_liv.arm_id }
                    # The SPARC record is present for the protocol
                    if cwf_li.deleted_at.nil?
                      # record was not deleted
                      row    += ["", "#{cwf_li.id} / #{cwf_li.sparc_id}", "#{cwf_li.arm.id} / #{cwf_li.arm.name}", cwf_li.sparc_service.abbreviation, cwf_li.subject_count, "", "", ""]
                      styles += cwf_li_styles(cwf_li, sparc_liv)
                    else
                      # record was deleted
                      row    += ["", "Line Item Deleted", "", "", "", "", "", ""]
                      styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                    end
                  else
                    # The SPARC record is missing for the protocol
                    row    += ["", "Line Item Missing", "", "", "", "", "", ""]
                    styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                  end
                end

                liv_rows[0]   << row
                liv_styles[0] << styles
              end

              sparc_protocol.line_items_visits.includes(:sub_service_request, line_item: :fulfillment_line_items).select{ |sparc_liv| sparc_liv.sub_service_request.in_work_fulfillment && sparc_liv.line_item.fulfillment_line_items.empty? }.each do |sparc_liv|
                sparc_li  = sparc_liv.line_item
                row       = ["#{sparc_li.id} / #{sparc_liv.id}", "#{sparc_liv.arm.id} / #{sparc_liv.arm.name}", sparc_liv.service.abbreviation, sparc_liv.subject_count, "", "", ""]
                styles    = sparc_li_styles(sparc_liv, sparc_li)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  row    += ["", "Line Item Missing", "", "", "", "", "", ""]
                  styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                liv_rows[1]   << row
                liv_styles[1] << styles
              end

              Shard::Fulfillment::LineItem.where(arm: Shard::Fulfillment::Arm.where(protocol: sparc_protocol.fulfillment_protocols.with_pppv_services)).select{ |cwf_li| cwf_li.sparc_line_item.nil? rescue true }.each do |cwf_li|
                if AuditRecovery.where(auditable_type: 'LineItem', auditable_id: cwf_li.sparc_id, action: 'destroy').any?
                  # The record was deleted in SPARCRequest
                  row     = ["Line Item Deleted", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                else
                  # There was never a record in SPARCRequest or the data is corrupted
                  row     = ["Line Item Missing", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_li.arm.protocol_id == cwf_protocol.id
                    row    += ["", "#{cwf_li.id} / #{cwf_li.sparc_id || 'NULL'}", "#{cwf_li.arm.id} / #{cwf_li.arm.name}", cwf_li.sparc_service.abbreviation, cwf_li.subject_count, "", "", ""]
                    styles += cwf_li_styles(cwf_li, nil)
                  else
                    row    += ["", "", "", "", "", "", "", ""]
                    styles += [@default, @default, @default, @default, @default, @default, @default, @default]
                  end
                end

                liv_rows[2]   << row
                liv_styles[2] << styles
              end

              ################
              # VISIT GROUPS #
              ################
              ### Get all Visit Groups in SPARC with corresponding Fulfillment Visit Groups
              ### Get all remaining SPARC Visit Groups without corresponding Fulfillment Visit Groups
              ### Get all remaining Fulfillment Visit Groups without corresponding SPARC Visit Groups

              sparc_vgs = sparc_protocol.visit_groups.includes(:arm, :fulfillment_visit_groups).select do |sparc_vg|
                sparc_vg.fulfillment_visit_groups.where.not(name: sparc_vg.name)
                  .or(sparc_vg.fulfillment_visit_groups.where.not(position: sparc_vg.position))
                  .or(sparc_vg.fulfillment_visit_groups.where.not(day: sparc_vg.day))
                  .or(sparc_vg.fulfillment_visit_groups.where.not(window_before: sparc_vg.window_before))
                  .or(sparc_vg.fulfillment_visit_groups.where.not(window_after: sparc_vg.window_after))
                  .or(sparc_vg.fulfillment_visit_groups.deleted)
                  .any?
              end

              sparc_vgs.each do |sparc_vg|
                row     = [sparc_vg.id, "#{sparc_vg.arm.id} / #{sparc_vg.arm.name}", sparc_vg.name, sparc_vg.position, sparc_vg.window_before, "#{sparc_vg.day || 'NULL'}", sparc_vg.window_after]
                styles  = sparc_vg_styles(sparc_vg)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_vg = sparc_vg.fulfillment_visit_groups.includes(:arm).detect{ |cwf_vg| cwf_vg.arm.try(:sparc_id) == sparc_vg.arm_id }
                    # The SPARC record is present for the protocol
                    if cwf_vg.deleted_at.nil?
                      # The record was not deleted
                      row    += ["", "#{cwf_vg.id} / #{cwf_vg.sparc_id}", "#{cwf_vg.arm.id} / #{cwf_vg.arm.name}", cwf_vg.name, cwf_vg.position, cwf_vg.window_before, "#{cwf_vg.day || 'NULL'}", cwf_vg.window_after]
                      styles += cwf_vg_styles(cwf_vg)
                    else
                      # The record was deleted
                      row    += ["", "Visit Group Deleted", "", "", "", "", "", ""]
                      styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                    end
                  else
                    # The SPARC record is missing for the protocol
                    row    += ["", "Visit Group Missing", "", "", "", "", "", ""]
                    styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                  end
                end

                vg_rows[0]   << row
                vg_styles[0] << styles
              end

              sparc_protocol.visit_groups.select{ |sparc_vg| sparc_vg.fulfillment_visit_groups.empty? }.each do |sparc_vg|
                row     = [sparc_vg.id, "#{sparc_vg.arm.id} / #{sparc_vg.arm.name}", sparc_vg.name, sparc_vg.position, sparc_vg.window_before, "#{sparc_vg.day || 'NULL'}", sparc_vg.window_after]
                styles  = sparc_vg_styles(sparc_vg)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  row    += ["", "Visit Group Missing", "", "", "", "", "", ""]
                  styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                vg_rows[1]   << row
                vg_styles[1] << styles
              end

              Shard::Fulfillment::VisitGroup.where(arm: Shard::Fulfillment::Arm.where(protocol: sparc_protocol.fulfillment_protocols.with_pppv_services)).select{ |cwf_vg| cwf_vg.sparc_visit_group.nil? rescue true }.each do |cwf_vg|
                if AuditRecovery.where(auditable_type: 'VisitGroup', auditable_id: cwf_vg.sparc_id, action: 'destroy')
                  # The record was deleted in SPARCRequest
                  row     = ["Visit Group Deleted", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                else
                  # There was never a record in SPARCRequest or the data is corrupted
                  row     = ["Visit Group Missing", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_vg.arm.protocol_id == cwf_protocol.id
                    row    += ["", "#{cwf_vg.id} / #{cwf_vg.sparc_id || 'NULL'}", "#{cwf_vg.arm.id} / #{cwf_vg.arm.name}", cwf_vg.name, cwf_vg.position, cwf_vg.window_before, "#{cwf_vg.day || 'NULL'}", cwf_vg.window_after]
                    styles += cwf_vg_styles(cwf_vg)
                  else
                    row    += ["", "", "", "", "", "", "", ""]
                    styles += [@default, @default, @default, @default, @default, @default, @default, @default]
                  end
                end

                vg_rows[2]   << row
                vg_styles[2] << styles
              end

              ##########
              # VISITS #
              ##########
              ### Get all Visits in SPARC with corresponding Fulfillment Visits
              ### Get all remaining SPARC Visits without corresponding Fulfillment Visits
              ### Get all remaining Fulfillment Visits without corresponding SPARC Visits
              sparc_visits = sparc_protocol.visits.includes(:arm, :visit_group, :sub_service_request, :fulfillment_visits).select do |sparc_visit|
                sparc_visit.sub_service_request.in_work_fulfillment &&
                  sparc_visit.fulfillment_visits.where.not(research_billing_qty: sparc_visit.research_billing_qty)
                    .or(sparc_visit.fulfillment_visits.where.not(insurance_billing_qty: sparc_visit.insurance_billing_qty))
                    .or(sparc_visit.fulfillment_visits.where.not(effort_billing_qty: sparc_visit.effort_billing_qty))
                    .or(sparc_visit.fulfillment_visits.deleted)
                    .any?
              end

              sparc_visits.each do |sparc_visit|
                row     = [sparc_visit.id, "#{sparc_visit.arm.id} / #{sparc_visit.arm.name}", "#{sparc_visit.line_item.id} / #{sparc_visit.line_items_visit.id} / #{sparc_visit.service.abbreviation}", "#{sparc_visit.visit_group.id} / #{sparc_visit.visit_group.name}", sparc_visit.research_billing_qty, sparc_visit.insurance_billing_qty, sparc_visit.effort_billing_qty]
                styles  = sparc_visit_styles(sparc_visit)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_visit = sparc_visit.fulfillment_visits.includes(:arm, :visit_group).detect{ |cwf_visit| cwf_visit.arm.protocol_id == cwf_protocol.id }
                    # The SPARC record is present for the protocol
                    if cwf_visit.deleted_at.nil?
                      # The record was not deleted
                      row    += ["", "#{cwf_visit.id} / #{cwf_visit.sparc_id}", "#{cwf_visit.arm.id} / #{cwf_visit.arm.name}", "#{cwf_visit.line_item.id} / #{cwf_visit.line_item.sparc_id || 'NULL'} / #{cwf_visit.line_item.sparc_service.abbreviation}", "#{cwf_visit.visit_group.id} / #{cwf_visit.visit_group.name}", cwf_visit.research_billing_qty, cwf_visit.insurance_billing_qty, cwf_visit.effort_billing_qty]
                      styles += cwf_visit_styles(cwf_visit)
                    else
                      # The record was deleted
                      row    += ["", "Visit Deleted", "", "", "", "", "", ""]
                      styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                    end
                  else
                    # The SPARC record is missing for the protocol
                    row    += ["", "Visit Missing", "", "", "", "", "", ""]
                    styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                  end
                end

                visit_rows[0]   << row
                visit_styles[0] << styles
              end

              sparc_protocol.visits.includes(:sub_service_request).select{ |sparc_visit| sparc_visit.sub_service_request.in_work_fulfillment && sparc_visit.fulfillment_visits.empty? }.each do |sparc_visit|
                row     = [sparc_visit.id, "#{sparc_visit.arm.id} / #{sparc_visit.arm.name}", "#{sparc_visit.line_item.id} / #{sparc_visit.line_items_visit.id} / #{sparc_visit.service.abbreviation}", "#{sparc_visit.visit_group.id} / #{sparc_visit.visit_group.name}", sparc_visit.research_billing_qty, sparc_visit.insurance_billing_qty, sparc_visit.effort_billing_qty]
                styles  = sparc_visit_styles(sparc_visit)

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  row    += ["", "Visit Missing", "", "", "", "", "", ""]
                  styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                visit_rows[1]   << row
                visit_styles[1] << styles
              end

              Shard::Fulfillment::Visit.where(line_item: Shard::Fulfillment::LineItem.where(arm: Shard::Fulfillment::Arm.where(protocol: sparc_protocol.fulfillment_protocols.with_pppv_services))).select{ |cwf_visit| cwf_visit.sparc_visit.nil? rescue true }.each do |cwf_visit|
                if AuditRecovery.where(auditable_type: 'Visit', auditable_id: cwf_visit.sparc_id, action: 'destroy')
                  # The record was deleted in SPARCRequest
                  row     = ["Visit Deleted", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                else
                  # There was never a record in SPARCRequest or the data is corrupted
                  row     = ["Visit Missing", "", "", "", "", "", ""]
                  styles  = [@data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
                end

                sparc_protocol.fulfillment_protocols.with_pppv_services.each do |cwf_protocol|
                  if cwf_visit.line_item.arm.protocol_id == cwf_protocol.id
                    row    += ["", "#{cwf_visit.id} / #{cwf_visit.sparc_id || 'NULL'}", "#{cwf_visit.arm.id} / #{cwf_visit.arm.name}", "#{cwf_visit.line_item.id} / #{cwf_visit.line_item.sparc_id || 'NULL'} / #{cwf_visit.line_item.sparc_service.abbreviation}", "#{cwf_visit.visit_group.id} / #{cwf_visit.visit_group.name}", cwf_visit.research_billing_qty, cwf_visit.insurance_billing_qty, cwf_visit.effort_billing_qty]
                    styles += cwf_visit_styles(cwf_visit)
                  else
                    row    += ["", "", "", "", "", "", "", ""]
                    styles += [@default, @default, @default, @default, @default, @default, @default, @default]
                  end
                end

                visit_rows[2]   << row
                visit_styles[2] << styles
              end

              ############
              # ADD ROWS #
              ############

              has_arms    = arm_rows.any?(&:any?)
              has_livs    = liv_rows.any?(&:any?)
              has_vgs     = vg_rows.any?(&:any?)
              has_visits  = visit_rows.any?(&:any?)

              if has_arms || has_livs || has_vgs || has_visits
                sheet.add_row header_row, style: header_styles

                if has_arms
                  sheet.add_row arm_header_row, style: arm_header_styles
                  sheet.add_row arm_sub_header_row, style: arm_sub_header_styles

                  arm_rows.each_with_index do |arms, i|
                    arms.each_with_index do |arm_row, j|
                      sheet.add_row arm_row, style: arm_styles[i][j]
                    end
                  end

                  sheet.add_row []
                end

                if has_livs
                  sheet.add_row li_header_row, style: li_header_styles
                  sheet.add_row li_sub_header_row, style: li_sub_header_styles

                  liv_rows.each_with_index do |livs, i|
                    livs.each_with_index do |liv_row, j|
                      sheet.add_row liv_row, style: liv_styles[i][j]
                    end
                  end

                  sheet.add_row []
                end

                if has_vgs
                  sheet.add_row vg_header_row, style: vg_header_styles
                  sheet.add_row vg_sub_header_row, style: vg_sub_header_styles

                  vg_rows.each_with_index do |vgs, i|
                    vgs.each_with_index do |vg_row, j|
                      sheet.add_row vg_row, style: vg_styles[i][j]
                    end
                  end

                  sheet.add_row []
                end

                if has_visits
                  sheet.add_row visit_header_row, style: visit_header_styles
                  sheet.add_row visit_sub_header_row, style: visit_sub_header_styles

                  visit_rows.each_with_index do |visits, i|
                    visits.each_with_index do |visit_row, j|
                      sheet.add_row visit_row, style: visit_styles[i][j]
                    end
                  end

                  sheet.add_row []
                end

                2.times{ sheet.add_row [] }
              end
            elsif (ssrs = sparc_protocol.sub_service_requests.includes(:fulfillment_protocol).where(in_work_fulfillment: true)).select{ |ssr| ssr.fulfillment_protocol.nil? }.any?
              ssrs.each do |missing_ssr|
                header_row    += ["", "CWF Protocol Missing (#{missing_ssr.display_id})", "", "", "", "", "", ""]
                header_styles += [@default, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error, @data_error]
              end

              sheet.add_row header_row, style: header_styles
              3.times{ sheet.add_row [] }
            end
          end
        end
      end
      p.serialize(Rails.root.join('tmp', 'fulfillment_sync_report.xlsx'))
    end
  end
end
