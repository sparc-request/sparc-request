module BulkCreateable
  module ClassMethods
    # Create n instances of the model with the given arguments.
    # Returns all the instances in an array.
    def bulk_create(n, args = {})
      records = []
    
      # Insert n items into the database
      for i in 1..n do
        rec = self.new(args)
        rec.save!
        records << rec
      end

      return records
    end
  end
end

