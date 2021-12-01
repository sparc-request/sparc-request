# Copyright © 2011-2020 MUSC Foundation for Research Development
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

module FeeAgreement
  class ClinicalServiceTable
    attr_reader :service_request, :arm, :visit_range, :visit_groups, :last_table_for_arm, :rows

    def initialize(service_request:, arm:, visit_range:, visit_groups:, last_table_for_arm:,
                   line_item_visits: [])
      @service_request = service_request
      @arm = arm
      @visit_range = visit_range
      @visit_groups = visit_groups
      @last_table_for_arm = last_table_for_arm
      @rows = line_item_visits.map do |liv|
        visits = liv.ordered_visits
                    .select { |visit| visit_groups.include? visit.visit_group }

        ClinicalServiceRow.build(liv, visits, last_table_for_arm)
      end
    end

    def name
      if visit_range.size == 1
        arm.name
      else
        "#{arm.name} - Visit #{visit_range.first} to #{visit_range.last}"
      end
    end

    def rows_by_program
      rows.group_by { |r| r.program_name }
    end

    # Visit column headers
    def visit_columns
      visit_groups.map { |group| "Visit #{group.position} (#{group.name}) Day #{group.day}" }
    end

    # Per-patient program total for visit n.
    #
    # @param program_name:String - program of interest
    # @param visit_position:Integer - visit number
    #
    def visit_subtotal(program_name, visit_position)
      raise "Position should be greater than 0" if visit_position < 1

      program_rows = rows.select { |row| row.program_name == program_name }

      if program_rows
        visit_costs = program_rows.map do |row|
          visit = row.visits.find { |visit| visit.position == visit_position }
          (row.service_cost * visit.research_billing_qty) if visit
        end

        Service.cents_to_dollars(visit_costs.compact.sum)
      end
    end

    # Per-study ; sum of all of the per_service_total values
    # @returns - amount in dollars
    def line_item_total(program_name)
      if last_table_for_arm
        rows.select { |row| row.program_name == program_name }.sum(&:per_service_total)
      end
    end

    def visit_total(visit_position)
      visit_costs = rows.map do |row|
        visit = row.visits.find { |visit| visit.position == visit_position }
        (row.service_cost * visit.research_billing_qty) if visit
      end
      Service.cents_to_dollars(visit_costs.compact.sum)
    end

    def total
      if last_table_for_arm
        rows.sum(&:per_service_total)
      end
    end
  end

  # Represents a row in a ClinicalServiceTable.
  class ClinicalServiceRow
    attr_reader :program_name, :service_name, :service_cost, :unit, :enrollment, :visits,
                :per_service_total, :service_notes

    def initialize(program_name:, service_name:, service_cost:, unit:, enrollment:, visits:,
                   per_service_total: nil, service_notes: nil)

      @program_name = program_name
      @service_name = service_name
      @service_cost = service_cost
      @unit = unit
      @enrollment = enrollment
      @visits = visits
      @per_service_total = per_service_total
      @service_notes = service_notes
    end

    # @param line_items_visit : LineItemsVisit
    # @param visits : List[Visit] - subset of visit columns to display
    # @param show_summary : Boolean - indicates whether to display the summary columns; this should
    #   be set to true if the row is for the last table in an Arm.
    #
    # @returns ClinicalServiceRow
    def self.build(line_items_visit, visits, show_summary = false)
      per_service_total = nil
      notes = nil
      if show_summary
        direct_costs = line_items_visit.direct_costs_for_visit_based_service_single_subject
        per_service_total = Service.cents_to_dollars(direct_costs * line_items_visit.subject_count)
        notes = line_items_visit.notes.map(&:body).join("; ")
      end

      ClinicalServiceRow.new(
        program_name: line_items_visit.line_item.service.organization.name,
        service_name: line_items_visit.line_item.service.name,
        service_cost: line_items_visit.line_item.applicable_rate,
        unit: line_items_visit.line_item.service.displayed_pricing_map.unit_type.gsub("/", "/ "),
        enrollment: line_items_visit.subject_count,
        visits: visits,
        per_service_total: per_service_total,
        service_notes: notes
      )
    end

    def displayed_service_cost
      Service.cents_to_dollars(service_cost)
    end

    def visit_quantities
      visits.map(&:research_billing_qty)
    end
  end

  # Table data for displaying non-clinical service information.
  class NonClinicalServiceTable
    attr_reader :rows

    def initialize(service_request, filters = {})
      @rows = otf_line_items_to_display(service_request, filters).map do |li|
        NonClinicalServiceRow.new(li)
      end
    end

    def total
      @total ||= @rows.map(&:total).compact.sum
    end

    # Adapted from Dashboard::ServiceCalendar.otf_line_items_to_display
    def otf_line_items_to_display(service_request, filters)
      statuses_hidden = %w(first_draft draft)

      query = service_request.line_items
                             .eager_load(:admin_rates, :notes, :service_request)
                             .includes(sub_service_request: :organization,
                                       service: [:pricing_maps,
                                                 organization: [:pricing_setups,
                                                                parent: [:pricing_setups,
                                                                         parent: [:pricing_setups,
                                                                                  :parent]]]])
                             .where.not(sub_service_requests: { status: statuses_hidden })
                             .where(services: { one_time_fee: true })
      # Apply user-defined filters
      if filters[:status] and !filters[:status].empty?
        query = query.where(sub_service_requests: { status: filters[:status] })
      end

      if filters[:program] and !filters[:program].empty?
        query = query.where(sub_service_requests: { :organization_id => filters[:program] })
      end
      query
    end
  end

  # Represents a row in a NonClinicalServiceTable.
  class NonClinicalServiceRow
    attr_reader :program_name, :service_name, :service_cost, :quantity, :total

    # @param line_item : LineItem
    def initialize(line_item)
      @program_name = line_item.service.organization.name
      @service_name = line_item.service.name
      @service_cost = line_item.applicable_rate
      @quantity = line_item.quantity
      @total = Service.cents_to_dollars(@service_cost * @quantity)
    end

    def displayed_service_cost
      Service.cents_to_dollars(service_cost)
    end
  end

  # Fee Agreement report; contains tables with fee agreement data for clinical and non-clinical
  # services. The report can be filtered by Program and request Status.
  class Report
    attr_reader :clinical_service_tables, :non_clinical_service_table, :clinical_total,
                :grand_total, :filters, :service_request

    # @param service_request: ServiceRequest - request to summarize
    # @param filters : Hash - see filter_options for expected values.
    # @param max_visit_columns_per_table : Number ; clinical services can be split into multiple
    #   tables so they can easily be printed. Each table will have at most this number of visit
    #   columns.
    def initialize(service_request, filters = {}, max_visit_columns_per_table = 5)
      @service_request = service_request
      @filters = filters
      @visit_columns = max_visit_columns_per_table

      @clinical_service_tables = init_clinical_service_tables()
      @non_clinical_service_table = NonClinicalServiceTable.new(@service_request, @filters)
      @clinical_total = @clinical_service_tables.map(&:total).compact.sum
      @grand_total = @clinical_total + @non_clinical_service_table.total
    end

    # @returns Hash of options to use for filtering data.
    def filter_options
      unless @filter_options
        @filter_options = {}
        @filter_options[:status] = PermissibleValue.get_hash('status')
        proj_statuses = @service_request.sub_service_requests.map(&:status)
        unless proj_statuses.empty?
          @filter_options[:status].select! { |val, _| proj_statuses.include?(val) }
        end

        programs = @service_request.sub_service_requests.map do |ssr|
          ssr.org_tree.select { |org| org.type == 'Program' }
        end
        @filter_options[:program] = programs.flatten.map { |org| [org.id, org.name] }.to_h
      end
      @filter_options
    end

    # @returns List[ClinicalServiceTable]
    def init_clinical_service_tables()
      tables = []
      @service_request.arms.map do |arm|
        # Partition visit groups into separate tables so they fit on a page. All non-visit columns
        # are repeated for each table.

        FeeAgreement.visit_ranges(arm.visit_groups.size, @visit_columns).map do |visit_range|
          tables << ClinicalServiceTable.new(
            service_request: @service_request,
            arm: arm,
            visit_range: visit_range,
            visit_groups: arm.visit_groups.where(position: visit_range),
            last_table_for_arm: (visit_range.last == arm.visit_groups.size),
            line_item_visits: line_item_visits(arm)
          )
        end
      end
      # clear cache
      @livs = {}
      tables.flatten
    end

    def line_item_visits(arm)
      # cache results
      @livs ||= {}
      @livs[[arm.id, @service_request.id]] ||= FeeAgreement.pppv_line_items_visits_to_display(arm, @filters)
    end
  end

  # Adapted from Dashboard::ServiceCalendars#pppv_line_items_visits_to_display
  # @param arm : Arm
  # @param filters : Hash - user defined filters for status and program
  # @returns List[LineItemVisit]
  def self.pppv_line_items_visits_to_display(arm, filters = {})
    statuses_hidden = %w(first_draft draft)

    query = arm.line_items_visits
               .eager_load(:visits, :notes)
               .includes(sub_service_request: :organization,
                         line_item: [:admin_rates, :service_request,
                                     service: [:pricing_maps,
                                               organization: [:pricing_setups,
                                                              parent: [:pricing_setups,
                                                                       parent: [:pricing_setups,
                                                                                :parent]]]]])
               .where.not(sub_service_requests: { status: statuses_hidden })
               .where(services: { one_time_fee: false })
               .where.not("research_billing_qty = 0 and insurance_billing_qty = 0 and effort_billing_qty = 0")

    # Apply user-defined filters
    if filters[:status] and !filters[:status].empty?
      query = query.where(sub_service_requests: { status: filters[:status] })
    end

    if filters[:program] and !filters[:program].empty?
      query = query.where(sub_service_requests: { :organization_id => filters[:program] })
    end
    query
  end

  # @param num_visits: Integer - total number of visits
  # @param max_visit_columns_per_table - max columns to fit the page width
  # @return List[Range], where ranges are 1-based and correspond with the visit position (column).
  def self.visit_ranges(num_visits, max_visit_columns_per_table)
    FeeAgreement.ranges(num_visits, max_visit_columns_per_table).map do |r|
      # map indices to positions
      position_start = r.first + 1
      position_end = (r.last + 1) > num_visits ? num_visits : (r.last + 1)
      position_start..position_end
    end
  end

  # Generates a list of ranges used to slice an array into chunks no larger
  # than the given chunk size.
  #
  # @param array_size: Number - size of the array to chunk
  # @param max_chunk_size: Number - maximum chunk size
  # @returns List[Range]
  def self.ranges(array_size, max_chunk_size = 1000)
    start = 0
    stop = max_chunk_size
    data = []
    while start < array_size
      data << (start..stop - 1)
      start = stop
      stop = stop + max_chunk_size
    end
    data
  end
end
