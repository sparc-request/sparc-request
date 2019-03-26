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

class MigrateProtocolAmountsToIntegers < ActiveRecord::Migration[5.1]
  def up
    query = Protocol.where.not(initial_amount: nil).or(
      Protocol.where.not(initial_amount_clinical_services: nil)).or(
      Protocol.where.not(negotiated_amount: nil)).or(
      Protocol.where.not(negotiated_amount_clinical_services: nil))

    protocols = {}
    query.each do |p|
      protocols[p.id] = {
        initial_amount: p.initial_amount,
        initial_amount_clinical_services: p.initial_amount_clinical_services,
        negotiated_amount: p.negotiated_amount,
        negotiated_amount_clinical_services: p.negotiated_amount_clinical_services
      }
    end

    query.update_all(initial_amount: nil, initial_amount_clinical_services: nil, negotiated_amount: nil, negotiated_amount_clinical_services: nil)

    change_column :protocols, :initial_amount, :integer
    change_column :protocols, :initial_amount_clinical_services, :integer
    change_column :protocols, :negotiated_amount, :integer
    change_column :protocols, :negotiated_amount_clinical_services, :integer

    Protocol.reset_column_information

    query.each do |protocol|
      old_record = protocols[protocol.id]

      protocol.reload

      protocol.update_attribute(:initial_amount, (old_record[:initial_amount] * 100).to_i)                                            if old_record[:initial_amount]
      protocol.update_attribute(:initial_amount_clinical_services, (old_record[:initial_amount_clinical_services] * 100).to_i)        if old_record[:initial_amount_clinical_services]
      protocol.update_attribute(:negotiated_amount, (old_record[:negotiated_amount] * 100).to_i)                                      if old_record[:negotiated_amount]
      protocol.update_attribute(:negotiated_amount_clinical_services, (old_record[:negotiated_amount_clinical_services] * 100).to_i)  if old_record[:negotiated_amount_clinical_services]
    end
  end

  def down
    query = Protocol.where.not(initial_amount: nil).or(
      Protocol.where.not(initial_amount_clinical_services: nil)).or(
      Protocol.where.not(negotiated_amount: nil)).or(
      Protocol.where.not(negotiated_amount_clinical_services: nil))

    protocols = {}
    query.each do |p|
      protocols[p.id] = {
        initial_amount: p.initial_amount,
        initial_amount_clinical_services: p.initial_amount_clinical_services,
        negotiated_amount: p.negotiated_amount,
        negotiated_amount_clinical_services: p.negotiated_amount_clinical_services
      }
    end

    # Prevent out-of-range errors from MySQL
    query.update_all(initial_amount: nil, initial_amount_clinical_services: nil, negotiated_amount: nil, negotiated_amount_clinical_services: nil)

    change_column :protocols, :initial_amount, :decimal, precision: 8, scale: 2
    change_column :protocols, :initial_amount_clinical_services, :decimal, precision: 8, scale: 2
    change_column :protocols, :negotiated_amount, :decimal, precision: 8, scale: 2
    change_column :protocols, :negotiated_amount_clinical_services, :decimal, precision: 8, scale: 2

    Protocol.reset_column_information

    query.each do |protocol|
      old_record = protocols[protocol.id]

      protocol.reload

      protocol.update_attribute(:initial_amount, old_record[:initial_amount] / 100.0)                                           if old_record[:initial_amount]
      protocol.update_attribute(:initial_amount_clinical_services, old_record[:initial_amount_clinical_services] / 100.0)       if old_record[:initial_amount_clinical_services]
      protocol.update_attribute(:negotiated_amount, old_record[:negotiated_amount] / 100.0)                                     if old_record[:negotiated_amount]
      protocol.update_attribute(:negotiated_amount_clinical_services, old_record[:negotiated_amount_clinical_services] / 100.0) if old_record[:negotiated_amount_clinical_services]
    end
  end
end
