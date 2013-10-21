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
      p.workbook.add_worksheet(:name => "Data") do |sheet|
        create_report sheet
      end
      p.serialize(temp.path)
    end

    return temp
  end

  def to_csv
    temp = Tempfile.new("report.csv")
    CSV.open(temp.path, "wb") do |csv|
      create_report csv
    end

    return temp
  end

private

  def report_params
    self.params.except("type").map{|k,v| [k.titleize, v]}
  end

  def create_report obj
      create_report_header obj

      obj.add_row extract_header_row

      self.records.each do |record|
        obj.add_row extract_row(record)
      end
  end

  def create_report_header obj
      obj.add_row ["Report Generated:", Date.today.strftime("%Y-%m-%d")] 

      obj.add_row [""]

      obj.add_row ["Report Parameters"]
      obj.add_row ["Type:", self.title]
      report_params.each do |rp|
        obj.add_row extract_report_param_row(rp)
      end
      
      obj.add_row [""]
  end

  def extract_header_row
    self.attrs.keys.map{|x| x.is_a?(Class) ? x.to_s.titleize : x}
  end

  def extract_report_param_row rp
    k,v = rp

    value = v
    klass = k.safe_constantize

    if self.attrs.keys.include? klass # we've matched a class in our attrs hash
      obj = klass.find(v)
     
      m = self.attrs[klass][1]

      if m.is_a? Hash
        value = m[obj.id]
      else
        value = obj.instance_eval(m.to_s)
      end
    end
    
    return ["#{k}:", value]
  end

  def extract_row record
    row = self.attrs.map do |k,v| 
      # attribute is a class and not a string
      if k.is_a?(Class)
        if v[1] == true # this is a static piece of data and has already been loaded
          display = v[0]
        else
          obj = k.find(v[0].to_i)

          if v[1].is_a? Hash
            display = v[1][obj.id]
          else
            display = obj.instance_eval(v[1].to_s)
          end
          
          #display = obj.respond_to?(v[1]) ? obj.abbreviation : obj.name
          
          self.attrs[k] = [display, true]
        end

        display # return value for class 

      # attribute is a string and not a class
      else 
        if v[1].is_a? Hash
          v[1][record.instance_eval(v[0].to_s)] # return value if hash lookup is provided
        else
          record.instance_eval(v.to_s)
        end
      end
    end

    row
  end

  def method_missing(method, *args, &block)
    raise "#{method.to_s} needs to be defined in your report.  See app/reports/test_report.rb for examples"
  end
end
