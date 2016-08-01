# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
desc 'JIT report'
task :jit_report => :environment do
  ssrs = SubServiceRequest.where(:organization_id => 14, :status => 'ctrc_approved')

  CSV.open("tmp/jit_report.csv", "w+") do |csv|
    csv << ['Original Submit At Date', 'SPARC ID', 'Provider/Program', 'Primary PI', 'Title', 'Name of IRB', 'IRB # (either HR# or Pro#)', 'Date of most recent IRB approval']

    ssrs.each do |ssr|
      first_submit = ssr.past_statuses.where(:status => 'submitted').first.date
      protocol = ssr.service_request.protocol
      human_subjects_info = protocol.human_subjects_info
      csv << [first_submit.strftime('%m/%d/%y'), ssr.display_id, ssr.organization.name, protocol.primary_principal_investigator.display_name,
        protocol.title, human_subjects_info.irb_of_record, human_subjects_info.irb_and_pro_numbers, (human_subjects_info.irb_approval_date.strftime('%m/%d/%y') rescue nil)]
    end
  end
end
