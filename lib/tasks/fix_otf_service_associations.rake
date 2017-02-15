task fix_otf_service_associations: :environment do
  LineItem.all.each do |line_item|
    if line_item.one_time_fee
      line_item.line_items_visits.destroy
    end
  end

  Arm.all.each do |arm|
    unless arm.line_items_visits.present?
      arm.destroy
    end
  end
end
