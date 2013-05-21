# Base class for reports.  A report class must inherit from Report in
# order to be run from the report runner.
class Report
  @reports = [ ]

  # Grab a list of all reports and put them into @reports
  def self.inherited(klass)
    @reports << klass
  end

  # Return a list of all reports
  def self.all
    return @reports
  end

  # Run a report, e.g.:
  #
  # CtrcServicesReport.run
  #
  def self.run(*args)
    report = self.new(*args)
    report.run
  end

  # Return a report's description.  By default this is just a humanized
  # version of the class name; a report may override this method to
  # provide a more detailed description.
  #
  # Example:
  #
  #   CtrcServicesReport.description #=> "Ctrc services report"
  #
  def self.description
    return self.name.underscore.humanize
  end

  # Initialize a report class (running of the report is done with the
  # instance method #run).  The arguments specified on the command-line
  # are passed in here.
  def initialize(*args)
  end

  # Run a report.  This method must be defined by the derived class.
  def run
    raise NotImplementedError
  end
end

