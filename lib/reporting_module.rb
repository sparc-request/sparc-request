require 'csv'

class ReportingModule
  attr_reader :title, :options
  attr_accessor :params, :attrs
  
  def self.title
    self.class.name.titleize
  end

  def initialize params={}
    @title = self.class.title
    @options = default_options
    @params = params.delete_if {|k,v| v.blank?} 
    @attrs = column_attrs.delete_if {|k,v| v.blank?}
  end

  def records
    self.table.includes(self.includes)
              .where(self.where(self.params))
              .uniq(self.uniq)
              .group(self.group)
              .order(self.order)
  end

  def to_csv
    csv_string = CSV.generate do |csv|
      csv << self.attrs.keys.map{|x| x.is_a?(Class) ? x.to_s.titleize : x}

      self.records.each do |record|
        row = self.attrs.map do |k,v| 
          # attribute is a class and not a string
          if k.is_a?(Class)
            if v[1] == true # this is a static piece of data and has already been loaded
              display = v[0]
            else
              obj = k.find(v[0].to_i)

              if obj.respond_to?(v[1]) # this a method
                display = obj.send(v[1])
              elsif v[1].is_a? Hash
                display = v[1][obj.id]
              end
              
              #display = obj.respond_to?(v[1]) ? obj.abbreviation : obj.name
              
              self.attrs[k] = [display, true]
            end

            display # return value for class 

          # attribute is a string and not a class
          else 
            if v[1].is_a? Hash
              v[1][record.send(v[0])] # return value if hash lookup is provided
            else
              record.send(v) # otherwise assume value provided is what we want
            end
          end
        end

        csv << row
      end
    end
    csv_string
  end

  def method_missing(method, *args, &block)
    raise "#{method.to_s} needs to be defined in your report.  See app/reports/test_report.rb for examples"
  end
end
