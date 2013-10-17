require 'csv'

class ReportingModule
  attr_reader :title, :options
  attr_accessor :params, :attrs

  def initialize params={}
    @title = self.class.name.titleize
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
          if k.is_a?(Class)
            if v.is_a?(Array)
              display = v[0]
            else
              obj = k.find(v.to_i)
              display = obj.respond_to?(:abbreviation) ? obj.abbreviation : obj.name
              self.attrs[k] = [display, true]
            end
            display
          else 
            record.send(v)
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
