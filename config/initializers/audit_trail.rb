module Audited
  module Auditor
    module AuditedInstanceMethods
      def audit_trail(start_date, end_date)
        audits.where("created_at between ? and ?", start_date, end_date)
      end
    end
  end
end

