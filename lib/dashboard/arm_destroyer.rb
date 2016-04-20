module Dashboard
  class ArmDestroyer
    attr_reader :service_request, :sub_service_request, :selected_arm

    def initialize(params)
      @arm = Arm.find(params[:id])
    end

    def destroy
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      arm.destroy

      @service_request = @sub_service_request.service_request

      if @service_request.arms.any?
        @service_request.per_patient_per_visit_line_items.each(&:destroy)
      else
        @selected_arm = @service_request.arms.first
      end
    end
  end
end
