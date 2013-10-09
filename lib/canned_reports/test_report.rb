class TestReport < ReportingModule
  def options
    {
      Institution => {:field_type => :select},
      Provider => {:field_type => :select, :dependencies => ['institution_id']},
      Program => {:field_type => :select, :dependencies => ['provider_id']},
      "Date Range" => {:field_type => :date_range, :start => Date.today, :end => Date.today + 12},
    }
  end
end
