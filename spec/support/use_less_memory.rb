# Upon profiling, it seems we are spending 55% of our time in the
# garbage collector, because we are holding on to objects much longer
# than we should.  This patch does two things:
#
#   1) it disables running the garbage collector during a test and only
#      runs the garbage collector when the test completes
#   2) it removes any instance variables from the test object after the
#      test finishes (allowing the objects referenced by the test object
#      to be freed)
#
# The most important instance variable that is removed is @__memoized,
# which holds all the variables defined by let/let!.
#
# Source: http://blog.carbonfive.com/2011/02/02/crank-your-specs/

RSpec.configure do |config|
  RESERVED_IVARS = %w(@loaded_fixtures)
  last_gc_run = Time.now
 
  # Disable the garbage collector before starting each test
  config.before(:each) do
    # puts "Turning off garbage collector"
    GC.disable
  end
 
  config.after(:each) do
    # Remove any instance variables in this test object (the one that
    # just completed)
    (instance_variables - RESERVED_IVARS).each do |ivar|
      instance_variable_set(ivar, nil)
    end

    # DatabaseCleaner issues a ROLLBACK statement, but does not complete
    # the transaction; this causes the list of current transaction
    # records to grow without bound, and no activerecord objects are ever
    # cleaned up (see https://github.com/bmabey/database_cleaner/issues/204).
    # This works around the problem.  The assumption is that we have
    # only one connection to the database and it is accessible via
    # #shared_connection (see support/active_record.rb).
    if DatabaseCleaner.connections.any? { |conn| conn.strategy == :transaction } then
      ObjectSpace.each_object(ActiveRecord::Base) do |conn|
        conn.instance_eval { @_current_transaction_records = [ [ ] ] }
      end
    end

    # Run the garbage collector if it hasn't been run in over a second
    if Time.now - last_gc_run > 1.0 then
      GC.enable
      GC.start
      last_gc_run = Time.now
    end
  end
end

