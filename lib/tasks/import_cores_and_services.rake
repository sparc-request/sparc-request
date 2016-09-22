# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

namespace :data do
  desc "Import cores and services from CSV"
  task :import_cores_and_services, [:uid_domain] => :environment do |t, args|
    if args[:uid_domain]
      CSV.foreach("services.csv", :headers => true) do |row|
        # Institution	Provider	Program	Administration	Service	Service Description (1 sentence to a few paragraphs)	Order (order of service display)	Hide from users? (Y/N)	Clinical Work Fullfillment (Y/N)	Nexus (Y/N)	Display Date Pricing	Effective Date Pricing 	Rate (full)	PP or OT? PP= Per Patient, OT=One Time	PP Quantity Type	PP Units Factor	PP Quant Min	OT Quantity Type	OT Quant Min	OT Unit Type	OT Unit Factor	OT Unit Max	Related Service?	Dependancy (Name of service exactly)	Super User (please provide hawkid(s))	Service Provider(s)	Catalog Manager(s) Rights (please provide hawkid)	Submission Email (please provide email address(s))  
        if row[0] and row[1] and row[2] and row[4]
          institution = Institution.where(:name => row[0]).first
          if institution
            provider = institution.providers.where(:name => row[1]).first
            if provider
              program = provider.programs.where(:name => row[2]).first
              if program
                if program.has_active_pricing_setup
                  service = nil
                  organization_id = program.id
                  if row[3]
                    core = program.cores.where(:name => row[3]).first
                    if core
                      service = core.services.where(:name => row[4]).first
                      if service
                        puts "Service["+row[4]+"] already exists in Core["+row[3].to_s+"] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"         
                      else
                        organization_id = core.id
                        # create below...
                      end
                    else
                      # create core
                      core = program.cores.new(:name => row[3],
                                          :abbreviation => row[3],
                                          :order => 1,
                                        #  :organization_id => organization_id,
                                          :is_available => (row[7] == 'N' ? true : false))
                      core.tag_list.add("clinical work fulfillment") if row[8] == 'Y' 
                      core.tag_list.add("ctrc") if row[9] == 'Y'                    
                      core.save
                      puts "Inserted: Core["+row[3].to_s+"] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"         
                      if row[24]
                        uids = row[24].split(',')
                        uids.each { |uid| 
                          full_uid = (uid << args[:uid_domain]).strip
                          super_user = core.super_users.new
                          super_user.identity = Identity.where(:ldap_uid => full_uid).first
                          raise "Error: super user ["+full_uid+"] not found in database" unless super_user.identity
                          if super_user.save
                            puts "Inserted: Super User["+full_uid+"] for Core["+row[3].to_s+"] "      
                          else
                            puts "NOT Inserted: Super User["+full_uid+"] for Core["+row[3].to_s+"] "      
                          end   
                        }   
                      end
                      
                      if row[25]
                        uids = row[25].split(',')
                        uids.each { |uid| 
                          full_uid = (uid << args[:uid_domain]).strip
                          service_provider = core.service_providers.new
                          service_provider.identity = Identity.where(:ldap_uid => full_uid).first
                          raise "Error: service provider ["+full_uid+"] not found in database" unless service_provider.identity
                          if service_provider.save
                            puts "Inserted: Service Provider["+full_uid+"] for Core["+row[3].to_s+"] "    
                          else
                            puts "NOT Inserted: Service Provider["+full_uid+"] for Core["+row[3].to_s+"] "    
                          end     
                        }   
                      else
                        puts "Warning: No Service Providers for Core["+row[3].to_s+"] " 
                      end   
                      
                      if row[26]
                        uids = row[26].split(',')
                        uids.each { |uid| 
                          full_uid = (uid << args[:uid_domain]).strip
                          catalog_manager = core.catalog_managers.new
                          catalog_manager.identity = Identity.where(:ldap_uid => full_uid).first
                          raise "Error: catalog_manager ["+full_uid+"] not found in database" unless catalog_manager.identity
                          if catalog_manager.save
                            puts "Inserted: Catalog Manager["+full_uid+"] for Core["+row[3].to_s+"] "   
                          else
                            puts "NOT Inserted: Catalog Manager["+full_uid+"] for Core["+row[3].to_s+"] "   
                          end      
                        } 
                      else
                        puts "Warning: No Catalog Managers for Core["+row[3].to_s+"] " 
                      end
                      
                      if row[27]
                        emails = row[27].split(',')
                        emails.each { |email| 
                          submission_email = core.submission_emails.new
                          submission_email.email = email.strip
                          if submission_email.save
                            puts "Inserted: Submission Email["+submission_email.email+"] for Core["+row[3].to_s+"] "         
                          else
                            puts "NOT Inserted: Submission Email["+submission_email.email+"] for Core["+row[3].to_s+"] "         
                          end
                        }     
                      end            
                      organization_id = core.id
                    end
                  else
                    service = program.services.where(:name => row[4]).first
                    if service
                      puts "Service["+row[4]+"] already exists in Program[" + row[2].to_s + "] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "]"      
                    else
                      # create below using program.id as organization_id...
                    end
                  end
                  # create new service if it doesn't already exist
                  if service.nil?
                    is_one_time_fee = (row[13] == 'OT' ? true : false)
                    service = Service.new(:name => row[4],
                                        :description => row[5],
                                        :abbreviation => row[4],
                                        :order => row[6],
                                        :organization_id => organization_id,
                                        :is_available => (row[7] == 'N' ? true : false),
                                        :one_time_fee => is_one_time_fee)         
      
                    pricing_map = service.pricing_maps.build(:display_date => Date.strptime(row[10], "%m/%d/%y"),
                                                          :effective_date => Date.strptime(row[11], "%m/%d/%y"),
                                                          :full_rate => Service.dollars_to_cents(row[12].to_s.strip.gsub("$", "").gsub(",", "")),
                                                          :unit_factor => (is_one_time_fee ? row[20] : row[15]), 
                                                          # one time fee specific fields
                                                          :units_per_qty_max => (is_one_time_fee ? row[21] : nil),
                                                          :otf_unit_type => (is_one_time_fee ? row[19] : nil), # one time fee unit type
                                                          :quantity_type => (is_one_time_fee ? row[17] : nil), # not used by per patient
                                                          :quantity_minimum => (is_one_time_fee ? row[18] : nil),
                                                          # per patient specific fields
                                                          :unit_type => (is_one_time_fee ? nil : row[14]), # per patient unit type
                                                          :unit_minimum => (is_one_time_fee ? nil : row[16]))
                    if service.save
                      # add a related service
                      if (row[22] == 'Y')
                        related_service = Service.where(name: row[23]).first
                        if related_service.blank?
                          puts "Error: Related Service" + row[23].to_s + " not found for Service[" + row[4].to_s + "] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"
                        elsif service.related_services.include? related_service
                          puts "Error: Related Service" + row[23].to_s + " already exists for Service[" + row[4].to_s + "] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"
                        else
                          service.service_relations.create :related_service_id => related_service.id, :optional => false
                          puts "Inserted: Related Service" + row[23].to_s + " for Service[" + row[4].to_s + "] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"
                        end
                      end
                      puts "Inserted: Service[" + row[4].to_s + "] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"
                      # associate Pricing Map
                      if pricing_map.save
                        puts "Inserted: Pricing Map for Service[" + row[4].to_s + "]"
                      else
                        puts "NOT Inserted: Pricing Map for Service[" + row[4].to_s + "]: "+ pricing_map.errors.full_messages.inspect
                      end  
                    else
                      puts "NOT Inserted: Service[" + row[4].to_s + "] for Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]: "+ service.errors.full_messages.inspect + pricing_map.errors.full_messages.inspect
                    end
                  end
                else
                  puts "Error: Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]  is missing an active pricing setup"         
                end
              else
                puts "Error: Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]  NOT found"         
              end
            else
              puts "Error: Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "] NOT found, and Program[" + row[2].to_s + "]"         
            end
          else
            puts "Error: Institution[" + row[0].to_s + "] NOT found, Provider[" + row[1].to_s + "], and Program[" + row[2].to_s + "]"         
          end
        else
          puts "Error: Institution[" + row[0].to_s + "], Provider[" + row[1].to_s + "], Program[" + row[2].to_s + "], and Service[" + row[4].to_s + "] must all be specified"         
        end
      end
    else
      puts "Error UID domain must be passed in as an argument"
    end    
  end
end