class RemoveApprovalColumnsFromSubServiceRequest < ActiveRecord::Migration[5.2]
  def change

    CSV.open("tmp/ssr_approvals.csv", "wb") do |csv|
      csv << [
        'Protocol ID',
        'SSR ID',
        'SSR Status',
        'SSR Creation Date',
        'SSR Updated Date',
        'Approval Type'
      ]

      SubServiceRequest.where('nursing_nutrition_approved = ? OR lab_approved = ? OR imaging_approved = ? OR committee_approved = ?', true, true, true, true).each do |ssr|
        if(ssr.nursing_nutrition_approved? && !ssr.approvals.exists?(approval_type: 'Nursing/Nutrition Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Nursing/Nutrition Approved']
        end

        if(ssr.lab_approved && !ssr.approvals.exists?(approval_type: 'Lab Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Lab Approved']
        end

        if(ssr.imaging_approved && !ssr.approvals.exists?(approval_type: 'Imaging Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Imaging Approved']
        end

        if(ssr.committee_approved && !ssr.approvals.exists?(approval_type: 'Committee Approved'))
          csv << [ssr.protocol_id,
            ssr.id,
            ssr.status,
            ssr.created_at,
            ssr.updated_at,
            'Committee Approved']
        end

      end

    end

    remove_column :sub_service_requests, :nursing_nutrition_approved
    remove_column :sub_service_requests, :lab_approved
    remove_column :sub_service_requests, :imaging_approved
    remove_column :sub_service_requests, :committee_approved
  end
end
