require "csv"
namespace :data do
  desc "Delete duplicated listings"
  task :id_duplicates => :environment do

  	def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end


  	def make_CSV(model, duplicate_data)
  		CSV.open("duplicated#{model.pluralize}.csv", "wb") do |csv|
  			csv << ["Group", "Field", "Count"]
  			duplicate_data.each do |k,count|
  				id, right = k.split(" ")
  				csv << [id, right, count] if count > 1
  			end
  		end
  	end
  	model = prompt "Enter the name of the model: "
  	group = prompt "Enter how data should be grouped: "
  	field = prompt "Enter the name of the field to inspect: "

  	model_data = model.classify.constantize.all#.group_by(&:project_role_id) #epic_rights_id.to_i
  	dups = Hash.new(0)
  	#h = {"1234" => [pr1, pr2]}
    model_data.each do |e|
    	dups["#{e.send(group)} #{e.send(field)}"] += 1
    end
	make_CSV(model, dups)
	
	end 
end

  				

  	
 