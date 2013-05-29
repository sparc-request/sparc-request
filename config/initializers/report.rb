# Report command, e.g.:
#
#   rails r report list
#   rails r report run <report>
#
def report
  # Require reports dynamically so that reports are not loaded as part
  # of the regular rails application
  require 'reports'
  run_report_command(ARGV)
end

