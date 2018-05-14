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
