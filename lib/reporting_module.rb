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
    records ||= self.table.includes(self.includes)
                    .joins(self.joins)
                    .where(self.where(self.params))
                    .uniq(self.uniq)
                    .group(self.group)
                    .order(self.order)
    records
  end

  def includes
  end

  def joins
  end

  def where
  end

  def uniq
  end

  def group
  end

  def order
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
      obj.add_row ["# of Records:", self.records.size]

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
    elsif self.default_options.keys.include?(klass) && self.default_options[klass].include?(:custom_name_method) # we've matched a class in our default_options hash, let's look for a custom_name_method
      obj = klass.find(v)
      value = obj.send(self.default_options[klass][:custom_name_method])
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
