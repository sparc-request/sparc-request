# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
desc "Complete procedures report"
task :complete_procedures_report => :environment do
  puts "######  Generating report ######"

  fs = 'industry' # funding source
  si = 49 # service id
  cas = "2014-07-01" # appointment completed_at start date
  cae = "2015-04-22" # appointment completed_at end date


  service = Service.find si

  data = Study.joins(:service_requests => [{:line_items => [{:procedures => :appointment}]}]).
               select("protocols.id, sum(procedures.r_quantity) as rqty, appointments.completed_at, appointments.visit_group_id, appointments.name, appointments.id as appt_id").
               where("protocols.funding_source = ? or protocols.potential_funding_source = ?", fs, fs).
               where("line_items.service_id = ?", si).
               where("procedures.completed = 1").
               where("appointments.completed_at between ? and ?", cas, cae).
               group("appointments.id").
               order("protocols.id")

  CSV.open(Rails.root.join("tmp", "completed_procedures_report_#{Time.now.strftime("%m%d%Y")}.csv"), "w+") do |csv|
    csv << ["Protocol ID", "PI Name", "Visit Name", "Procedure Name", "R Quantity", "Visit Completion Date"]

    data.each do |x|
      s = Study.find x.id
      a = Appointment.find x.appt_id

      pin = s.primary_principal_investigator.full_name rescue "No PI found"
      vgn = a.visit_group_id.present? ? a.visit_group.name : a.name

      csv << [x.id, pin, vgn, service.name, x.rqty, x.completed_at.strftime("%m/%d/%y")]
    end
  end

end
