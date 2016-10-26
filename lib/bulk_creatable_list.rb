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

