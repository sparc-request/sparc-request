# Handles Arm creation for Dashboard::ArmsController
module Dashboard
  class ArmBuilder
    attr_reader :arm

    # Creates new Arm with Arm#create
    # @param [Hash] attrs attributes for new Arm
    def initialize(attrs)
      @attrs = attrs
      @arm = Arm.create(attrs)
    end

    # Creates LineItemsVisits for each PPPV LineItem associated
    # with Arm's Protocol.
    # Sets default visit days for each of the Arm's VisitGroups.
    # If Protocol has any SubServiceRequests in work fulfillment,
    # then this populates the Arm's subjects.
    # @see Arm#create_line_items_visit
    # @see Arm#default_visit_days
    # @see Arm#populate_subjects
    def build
      return unless @arm.valid?
      protocol = Protocol.find(@attrs.fetch(:protocol_id))

      protocol.service_requests.flat_map(&:per_patient_per_visit_line_items).each do |li|
        @arm.create_line_items_visit(li)
      end

      @arm.default_visit_days
      @arm.reload

      # If any sub service requests under this arm's protocol are in CWF we need to build patient calendars
      if protocol.sub_service_requests.any?(&:in_work_fulfillment)
        @arm.populate_subjects
      end
    end
  end
end
