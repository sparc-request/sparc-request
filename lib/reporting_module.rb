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

  def to_excel
    temp = Tempfile.new("report.xlsx")
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
        sheet.add_row ["Simple Pie Chart"]
        %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
        sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
          chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
        end
      end
      p.serialize(temp.path)
    end

    return temp
  end

  def to_csv
    temp = Tempfile.new("report.csv")
    CSV.open(temp.path, "wb") do |csv|
      report_params = self.params.except("type").map{|k,v| [k.titleize, v]}
      
      csv << ["Report Generated:", Date.today.strftime("%Y-%m-%d")] 

      csv << [""]

      csv << ["Report Parameters"]
      csv << ["Type:", self.title]
      report_params.each do |k,v|
        value = v
        klass = k.safe_constantize

        if self.attrs.keys.include? klass # we've matched a class in our attrs hash
          value = klass.find(v).send(self.attrs[klass][1])
        end
           
        csv << ["#{k}:", value]
      end
      
      csv << [""]
      csv << self.attrs.keys.map{|x| x.is_a?(Class) ? x.to_s.titleize : x}

      self.records.each do |record|
        csv << extract_row(record)
      end
    end

    return temp
  end

private

  def extract_row record
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

    row
  end

  def method_missing(method, *args, &block)
    raise "#{method.to_s} needs to be defined in your report.  See app/reports/test_report.rb for examples"
  end
end
