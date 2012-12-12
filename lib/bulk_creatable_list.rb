# Here's a module to speed up the creation of multiple models that use
# acts_as_list.  DHH's acts_as_list extension does a SELECT for each
# record created; this optimization does only one SELECT.
module BulkCreateableList
  module ClassMethods
    # Create n instances of the model with the given arguments.
    # Returns all the instances in an array.
    def bulk_create(n, args = {})
      records = []

      # Get the largest position from the database
      max = self.where(args).maximum(:position) || 0
    
      # Insert n items into the database
      for i in 1..n do
        rec = self.new(args, :update_positions => false)
        rec.update_attributes!(:position => max + i)
        rec.save!
        rec.update_positions = true
        records << rec
      end

      return records
    end
  end

  module InstanceMethods
    attr_accessor :update_positions

    # Override initialize to allow :update_positions to be optionally
    # passed in
    def initialize(attributes = nil, options = { }, &block)
      super(attributes, options, &block)
      @update_positions = options.fetch(:update_positions, true)
    end

    # Override add_to_list_bottom to only update positions if
    # @update_positions is true
    def add_to_list_bottom
      super if @update_positions
    end

    # Override add_to_list_top to only update positions if
    # @update_positions is true
    def add_to_list_top
      super if @update_positions
    end

    # Override update_positions to only update positions if
    # @update_positions is true
    def update_positions
      super if @update_positions
    end
  end

  def self.included(klass)
    klass.instance_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
end

