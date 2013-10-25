# None of the following is applicable when using the :truncation
# DatabaseCleaner strategy.  However, I have left the comments here in
# case anyone wants to switch back to :transaction.
#
# Tests using the :transaction strategy can run into problems when
# multiple threads try to access the database at the same time.  For
# example, if the test thread starts a transaction, changes made in
# other threads might not get cleaned up by the test thread.  This can
# happen when using Capybara, which runs the server in one thread and
# the client in another.  The solution is to force all threads to share
# the same connection, e.g.:
# 
#   class ActiveRecord::Base
#     mattr_accessor :shared_connection
#     @@shared_connection = nil
#   
#   
#     def self.connection
#       @@shared_connection || retrieve_connection
#     end
#   end
#   
#   ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
#
# However, this fails for some tests with the exception:
#
#   Mysql2::Error: This connection is still waiting for a result
#
# The problem is that multiple threads are now trying to use the same
# connection object.  Mike Perham suggests using his ConnectionPool gem,
# which serializes access to the connection object:
# 
#   class ActiveRecord::Base
#     mattr_accessor :shared_connection
#     @@shared_connection = nil
#   
#     def self.connection
#       @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
#     end
#   end
#   
#   ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
#
# So if you want to use the :transaction DatabaseCleaner strategy,
# uncomment the above code.  However, at least one test breaks in this
# case, which is why we've switched to :truncation instead.
#
# http://www.spacevatican.org/2012/8/18/threading-the-rat/ proposes a
# possibly better solution (noting that using ConnectionPool he was
# still getting the exception occassionally).  However, I couldn't get
# the suggestion on that page to work.

