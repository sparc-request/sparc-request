# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

module Shard
  module Fulfillment
    class LineItem < Shard::Fulfillment::Base
      self.table_name = 'line_items'

      belongs_to :protocol
      belongs_to :arm

      has_many :visits, -> { joins(:visit_group).order('visit_groups.position') }
      has_many :fulfillments

      ##########################
      ### SPARC Associations ###
      ##########################

      belongs_to :sparc_line_item, class_name: '::LineItem', foreign_key: :sparc_id
      belongs_to :sparc_service, class_name: '::Service', foreign_key: :service_id

      def non_clinical?
        self.sparc_line_item.service.one_time_fee?
      end

      # Disable deletion of service in cart if in fulfillment
      def fulfilled?
        if non_clinical?
          fulfillments.exists?
        else
          arm.appointments.joins(:procedures).where(procedures: { service_id: service_id, status: %w[incomplete complete follow_up] }).exists?
        end
      end

      def deleted?
        self.deleted_at.present?
      end
    end
  end
end
