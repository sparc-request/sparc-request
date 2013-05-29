require 'optparse'
require 'fileutils'

# Base class for reports.  A report class must inherit from Report in
# order to be run from the report runner.
class Report
  attr_reader :output_file
  attr_reader :output_dir

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
  #   CtrcServicesReport.run(ARGV)
  #
  def self.run(args)
    report = self.new(args)
    report.setup
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
  # instance method #run).
  def initialize(args)
    @output_file = File.join(self.default_output_dir, self.default_output_file)
    parse(args)
  end

  # Parse run arguments passed in on the command line (called by
  # #initialize).
  def parse(args)
    opts = self.option_parser
    opts.parse(args)
  end

  # Create the OptionParser; override this in the derived class to add
  # new command-line options to a report.
  def option_parser
    opts = OptionParser.new
    opts.on('-o', '--output-file FILE') { |f| @output_file = f }
  end

  # Prepare to run a report (create output directory, etc.)
  def setup
    FileUtils.mkdir_p(File.dirname(@output_file))
  end

  # Run a report.  This method must be defined by the derived class.
  def run
    raise NotImplementedError
  end

  # Default output filename.
  # TODO: if all reports were xlsx or csv, then we could implement this
  # to call self.class.name.underscore
  def default_output_file
    raise NotImplementedError
  end

  # Default output directory.
  def default_output_dir
    return 'reports'
  end
end

