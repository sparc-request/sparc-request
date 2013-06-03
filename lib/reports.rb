require 'reports/report'

base = File.expand_path(File.dirname(__FILE__))

# Require all reports in the reports/ directory
Dir["#{base}/reports/*.rb"].each do |file|
  require file
end

def run_report_command(args = ARGV)
  cmd = args.shift

  case cmd
  when 'list'
    puts "Available reports:"
    reports = Report.all
    reports.sort_by! { |report| report.name }
    reports.each do |report|
      puts "  #{report.name.underscore} - #{report.description}"
    end

  when 'run'
    name = args.shift
    report = name.classify.constantize
    report.run(args)

  else
    puts "Available sub-commands:"
    puts "  list - gives a list of all availalbe reports"
    puts "  run <report> [<args>] - run a report"
  end
end

