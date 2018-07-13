desc "List Hb service pricing"
task :list_hb_services => :environment do

  CSV.open("tmp/hb_services_pricing_list.csv", "w+") do |csv|
    csv << ['EAP ID', 'Sparc Id', 'Service Name', 'Is Available', 'CPT Code', 'Revenue Code', 'Service Rate', 'Display Date', 'Effective Date']
    Service.all.each do |service|
      if service.eap_id? && service.revenue_code? && service.cpt_code?
        map = service.current_effective_pricing_map
        csv << [service.eap_id, service.id, service.name, service.is_available, service.cpt_code, service.revenue_code, map.full_rate / 100, map.display_date, map.effective_date]
      end
    end
  end
end