# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require "csv"
namespace :data do
  desc "Delete duplicated listings"
  task :id_duplicates => :environment do

      def prompt(*args)
        print(*args)
        STDIN.gets.strip
      end


      def make_CSV(model, duplicate_data)
        CSV.open("tmp/duplicated#{model.pluralize}.csv", "wb") do |csv|
          csv << ["Group", "Field", "Count"]
          duplicate_data.each do |k,count|
            id, right = k.split(" ")
            csv << [id, right, count] if count > 1
          end
        end
      end
      model = prompt "Enter the name of the model (EpicRight) : "
      group = prompt "Enter how data should be grouped (project_role_id): "
      uniq_group_id = prompt "Enter a unique #{group} (leave blank for all): "
      field = prompt "Enter the name of the field to inspect (right): "

      model_data = []
      if uniq_group_id.to_i >= 1
        model_data = model.constantize.where("#{group}" => uniq_group_id)
      else	
        model_data = model.constantize.all
      end

      dups = Hash.new(0)
      #h = {"1234" => [pr1, pr2]}
      model_data.each do |e|
        dups["#{e.send(group)} #{e.send(field)}"] += 1
      end
    make_CSV(model, dups)
    answer = nil 
    dups.each do |k,count|
      if count > 1
        answer = prompt "Duplicates were found. Would you like to proceed with repairing the data [Y/N]: "
        break
      else
        answer = "no dups found"
      end
    end
    if answer == "Y"
      puts "The following data would be deleted: "
      #modifiy dups 
      to_delete = []
      dups.each do |k, count|
        id, text = k.split (" ")
        if count > 1 
          to_delete << model.constantize.where("#{group}" => id, "#{field}" => text).limit(count - 1)
        end
      
      end
      puts to_delete.inspect
      answer2 = prompt "Are you sure you want to delete this data [Y/N]: "
      if answer2 == "Y"
        dups.each do |k, count|
          id, text = k.split (" ")
          records = model.constantize.where("#{group}" => id, "#{field}" => text)
          if count > 1 
            count -=1
            
            count.times do |num| 
              records[num].destroy
              puts "#{num} of #{k} destroyed"
            end
          end
        end
      else 
        puts "Ok data will remain unchanged"
      end
    elsif answer == 'no dups found' 
      puts "No duplicates found."
    else 
      puts "Ok. Data will remain unchanged."
    end
  end
end
