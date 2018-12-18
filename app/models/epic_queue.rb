# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class EpicQueue < ApplicationRecord
  audited

  belongs_to :protocol
  belongs_to :identity

  scope :search, -> (term) {
    return if term.blank?

    records = includes(:protocol).where(
      Protocol.arel_table[:type].matches("%#{term}%")
    ).or(
      includes(:protocol).where(Protocol.arel_table[:id].matches(term))
    ).or(
      includes(:protocol).where(Protocol.arel_table[:short_title].matches("%#{term}%"))
    ).or(
      includes(:protocol).where(Protocol.arel_table[:last_epic_push_status].matches("%#{term}%"))
    )

    identity_records = includes(:identity).where(
      Identity.arel_table[:first_name].matches("%#{term}%")
    ).or(
      includes(:identity).where(Identity.arel_table[:last_name].matches("%#{term}%"))
    )

    pi_records = unscoped.joins(protocol: :principal_investigators).where(
      Identity.arel_table[:first_name].matches("%#{term}%")
    ).or(
      unscoped.joins(protocol: :principal_investigators).where(Identity.arel_table[:last_name].matches("%#{term}%"))
    )

    where(id: records + identity_records + pi_records).distinct
  }

  scope :ordered, -> (sort, order) {
    if sort
      case sort
      when 'protocol'
        eager_load(:protocol).order(Arel.sql("protocols.id #{order}"))
      when 'pis'
        joins(protocol: :principal_investigators).order(Arel.sql("identities.first_name #{order}, identities.last_name #{order}"))
      when 'date'
        eager_load(:protocol).order(Arel.sql("protocol.last_epic_push_time #{order}"))
      when 'status'
        eager_load(:protocol).order(Arel.sql("protocol.last_epic_push_status #{order}"))
      when 'created_at'
        order(Arel.sql("epic_queues.created_at #{order}"))
      when 'name'
        eager_load(:identity).order(Arel.sql("identities.first_name #{order}, identities.last_name #{order}"))
      end
    else
      order(created_at: :desc)
    end
  }

  #This callback and the method below is probably incorrect. Any insight as to
  #why we would do this?

  #after_create :update_protocol

  #def update_protocol
  #  protocol.update_attributes({:last_epic_push_time => Time.now, :last_epic_push_status => 'complete'})
  #end
end

