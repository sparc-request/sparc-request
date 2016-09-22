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
    report = self.new
    report.setup(args)
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
  def initialize
    @output_file = File.join(self.default_output_dir, self.default_output_file)
  end

  # Parse arguments passed in on the command line (called by
  # #initialize).
  def parse_options(args)
    opts = OptionParser.new
    add_options(opts)
    opts.parse(args)
  end

  # Add options to the option parser; override this in the derived class
  # to add new command-line options to a report.
  def add_options(opts)
    opts.on('-o', '--output-file FILE') { |f| @output_file = f }
  end

  # Prepare to run a report (create output directory, etc.)
  def setup(args)
    parse_options(args)
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

