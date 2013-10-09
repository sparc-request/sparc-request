class ReportingModule
  attr_reader :title, :options

  def initialize
    @title = self.class.name.titleize
  end
end
