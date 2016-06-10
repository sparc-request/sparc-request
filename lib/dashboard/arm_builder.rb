# Handles Arm creation for Dashboard::ArmsController
module Dashboard
  class ArmBuilder
    attr_reader :arm

    # Creates new Arm with Arm#create
    # @param [Hash] attrs attributes for new Arm
    def initialize(attrs)
      @arm = Arm.create(attrs)
      return unless @arm.valid?

      protocol = Protocol.find(attrs[:protocol_id])

      protocol.service_requests.flat_map(&:per_patient_per_visit_line_items).each do |li|
        @arm.create_line_items_visit(li)
      end

      @arm.default_visit_days
    end
  end
end
