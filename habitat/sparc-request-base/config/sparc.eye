RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.dirname(__FILE__) + "/../../../")
RAILS_ENV = ENV["RAILS_ENV"] || "development"
RAILS_PORT = ENV["RAILS_PORT"] || "3000"

WORKERS_COUNT=1

Eye.application 'sparc' do
  env ENV.to_h
  working_dir RAILS_ROOT
#  env 'APP_ENV' => 'production' # global env for each processes
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes

  group 'web' do

    process :puma do
      daemonize true
      stdall "log/puma.log"
      pid_file "tmp/pids/puma.pid" # pid_path will be expanded with the working_dir
      start_command "bin/puma -p #{RAILS_PORT} -e #{RAILS_ENV}"
      stop_signals [:TERM, 5.seconds, :KILL]
      restart_command 'kill -USR2 {PID}'
      # when no stop_command or stop_signals, default stop is [:TERM, 0.5, :KILL]
      # default `restart` command is `stop; start`


      # ensure the CPU is below 30% at least 3 out of the last 5 times checked
      check :cpu, every: 30, below: 80, times: 3
    end
  end

  group 'jobs' do
    chain grace: 5.seconds
    (1..WORKERS_COUNT).each do |i|
      process "dj-#{i}" do
        pid_file "tmp/pids/delayed_job.#{i}.pid"
        start_command 'bin/delayed_job run'
        daemonize true
        stop_signals [:INT, 30.seconds, :TERM, 10.seconds, :KILL]
        stdall "log/dj-#{i}.log"
        # ensure the CPU is below 30% at least 3 out of the last 5 times checked
        check :cpu, every: 30, below: 80, times: 3
      end
    end
  end
end
