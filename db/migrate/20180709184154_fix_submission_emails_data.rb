class FixSubmissionEmailsData < ActiveRecord::Migration[5.2]
  def change
    SubmissionEmail.all.each do |sub_email|
      org = sub_email.organization
      next if org.process_ssrs

      if (process_ssrs_parent = org.process_ssrs_parent)
        ##process_ssrs is upstream
        unless process_ssrs_parent.submission_emails.map(&:email).include?(sub_email.email)
          process_ssrs_parent.submission_emails.create(organization_id: process_ssrs_parent.id, email: sub_email.email)
          puts "#{sub_email.email} added as submission email on Org ID: #{process_ssrs_parent.id} Name: #{process_ssrs_parent.name}"
        end
      else
        ##process_ssrs is downstream
        org.all_child_organizations.select{|x| x.process_ssrs}.each do |child_org|
          unless child_org.submission_emails.map(&:email).include?(sub_email.email)
            child_org.submission_emails.create(organization_id: child_org.id, email: sub_email.email)
            puts "#{sub_email.email} added as submission email on Org ID: #{child_org.id} Name: #{child_org.name}"
          end
        end
      end

      #destroy the bad data, even if neither scenario is true
      puts "Submission Email ID: #{sub_email.id} Email: #{sub_email.email} removed from non split/notify organization. Org ID: #{org.id} Name: #{org.name}"
      sub_email.destroy
    end
  end
end
