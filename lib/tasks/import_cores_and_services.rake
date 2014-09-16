namespace :data do
  desc "Import cores and services from CSV"
  task :import_cores_and_services, [:uid_domain] => :environment do |t, args|
    if args[:uid_domain]
      CSV.foreach("services.csv", :headers => true) do |row|
        # uid, first name, last name, email, institution, department, college  
        if row['Institution'] and row['Provider'] and row['Program'] and row['Service']
          institution = Institution.where(:name => row['Institution']).first
          if institution
            provider = institution.providers.where(:name => row['Provider']).first
            if provider
              program = provider.programs.where(:name => row['Program']).first
              if program
                if program.has_active_pricing_setup
                  service = nil
                  organization_id = program.id
                  if row['Core (this is optional)']
                    core = program.cores.where(:name => row['Core (this is optional)']).first
                    if core
                      service = core.services.where(:name => row['Service']).first
                      if service
                        puts "Service["+row['Service']+"] already exists in Core["+row['Core (this is optional)'].to_s+"] for Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]"         
                      else
                        organization_id = core.id
                        # create below...
                      end
                    else
                      # create core
                      core = program.cores.new(:name => row['Core (this is optional)'],
                                          :abbreviation => row['Core (this is optional)'],
                                          :order => 1,
                                        #  :organization_id => organization_id,
                                          :is_available => (row['Hide from users? (Y/N)'] == 'N' ? true : false))
                      core.save
                      puts "Inserted: Core["+row['Core (this is optional)'].to_s+"] for Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]"         
                      if row['Super User (please provide hawkid)']
                        uids = row['Super User (please provide hawkid)'].split(',')
                        uids.each { |uid| 
                          full_uid = (uid << args[:uid_domain]).strip
                          super_user = core.super_users.new
                          super_user.identity = Identity.where(:ldap_uid => full_uid).first
                          if super_user.save
                            puts "Inserted: Super User["+full_uid+"] for Core["+row['Core (this is optional)'].to_s+"] "      
                          else
                            puts "NOT Inserted: Super User["+full_uid+"] for Core["+row['Core (this is optional)'].to_s+"] "      
                          end   
                        }   
                      end
                      if row['Service Providers']
                        uids = row['Service Providers'].split(',')
                        uids.each { |uid| 
                          full_uid = (uid << args[:uid_domain]).strip
                          service_provider = core.service_providers.new
                          service_provider.identity = Identity.where(:ldap_uid => full_uid).first
                          if service_provider.save
                            puts "Inserted: Service Provider["+full_uid+"] for Core["+row['Core (this is optional)'].to_s+"] "    
                          else
                            puts "NOT Inserted: Service Provider["+full_uid+"] for Core["+row['Core (this is optional)'].to_s+"] "    
                          end     
                        }   
                      end   
                      if row['Catalog Manager(s) Rights (please provide hawkid)']
                        uids = row['Catalog Manager(s) Rights (please provide hawkid)'].split(',')
                        uids.each { |uid| 
                          full_uid = (uid << args[:uid_domain]).strip
                          catalog_manager = core.catalog_managers.new
                          catalog_manager.identity = Identity.where(:ldap_uid => full_uid).first
                          if catalog_manager.save
                            puts "Inserted: Catalog Manager["+full_uid+"] for Core["+row['Core (this is optional)'].to_s+"] "   
                          else
                            puts "NOT Inserted: Catalog Manager["+full_uid+"] for Core["+row['Core (this is optional)'].to_s+"] "   
                          end      
                        } 
                      end
                      if row['Submission Email (please provide email address)']
                        emails = row['Submission Email (please provide email address)'].split(',')
                        emails.each { |email| 
                          submission_email = core.submission_emails.new
                          submission_email.email = email.strip
                          if submission_email.save
                            puts "Inserted: Submission Email["+submission_email.email+"] for Core["+row['Core (this is optional)'].to_s+"] "         
                          else
                            puts "NOT Inserted: Submission Email["+submission_email.email+"] for Core["+row['Core (this is optional)'].to_s+"] "         
                          end
                        }     
                      end            
                      organization_id = core.id
                    end
                  else
                    service = program.services.where(:name => row['Service']).first
                    if service
                      puts "Service["+row['Service']+"] already exists in Program[" + row['Program'].to_s + "] for Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "]"      
                    else
                      # create below using program.id as organization_id...
                    end
                  end
                  # create new service if it doesn't already exist
                  if service.nil?
                    service = Service.new(:name => row['Service'],
                                        :description => row['Service Description (1 sentence to a few paragraphs)'],
                                        :abbreviation => row['Service'],
                                        :order => row['Order (order of service display)'],
                                        :organization_id => organization_id,
                                        :is_available => (row['Hide from users? (Y/N)'] == 'N' ? true : false))                  
                    service.tag_list.add("clinical work fulfillment") if row['Clinical Work Fullfillment (Y/N)'] == 'Y' 
                    service.tag_list.add("ctrc") if row['Nexus (Y/N)'] == 'Y'
                  
                    is_one_time_fee = (row['PP or OT? PP= Per Patient, OT=One Time'] == 'OT' ? true : false)
                    pricing_map = service.pricing_maps.build(:display_date => Date.strptime(row['Display Date Pricing'], "%m/%d/%y"),
                                                          :effective_date => Date.strptime(row['Effective Date Pricing '], "%m/%d/%y"),
                                                          :full_rate => Service.dollars_to_cents(row['Rate (full)'].to_s.strip.gsub("$", "").gsub(",", "")),
                                                          :is_one_time_fee => is_one_time_fee,
                                                          :unit_type => (is_one_time_fee ? row['OT Unit Type'] : nil),
                                                          :quantity_type => (is_one_time_fee ? row['OT Quantity Type'] : row['PP Quantity Type']),
                                                          :unit_factor => (is_one_time_fee ? row['OT Unit Factor'] : row['PP Units Factor']),
                                                          :units_per_qty_max => (is_one_time_fee ? row['OT Unit Max'] : nil),
                                                          :quantity_minimum => (is_one_time_fee ? row['OT Quant Min'] : row['PP Quant Min']))
                    if service.valid? and pricing_map.valid?
                      if service.save
                        puts "Inserted: Service[" + row['Service'].to_s + "] for Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]"
                      else
                        puts "NOT Inserted: Service[" + row['Service'].to_s + "] for Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]"
                      end
                      if pricing_map.save
                        puts "Inserted: Pricing Map for Service[" + row['Service'].to_s + "]"
                      else
                        puts "NOT Inserted: Pricing Map for Service[" + row['Service'].to_s + "]"
                      end
                    else
                      if !service.valid?
                        puts "Error: Service["+service.inspect+"] not valid: "+ service.errors
                      end
                      if !pricing_map.valid?
                        puts "Error: Pricing Map["+pricing_map.inspect+"] not valid: "+ pricing_map.errors
                      end
                    end
                  end
                else
                  puts "Error: Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]  is missing an active pricing setup"         
                end
              else
                puts "Error: Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]  NOT found"         
              end
            else
              puts "Error: Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "] NOT found, and Program[" + row['Program'].to_s + "]"         
            end
          else
            puts "Error: Institution[" + row['Institution'].to_s + "] NOT found, Provider[" + row['Provider'].to_s + "], and Program[" + row['Program'].to_s + "]"         
          end
        else
          puts "Error: Institution[" + row['Institution'].to_s + "], Provider[" + row['Provider'].to_s + "], Program[" + row['Program'].to_s + "], and Service[" + row['Service'].to_s + "] must all be specified"         
        end
      end
    else
      puts "Error UID domain must be passed in as an argument"
    end    
  end
end

