require 'equivalent-xml'

module RSpec::Matchers
  alias_method :__orig_be_equivalent_to, :be_equivalent_to

  # Better error formatting for be_equivalent_to
  def be_equivalent_to(expected)
    # Get a reference to the original Matcher object
    matcher = __orig_be_equivalent_to(expected)

    # Redefine the failure message
    matcher.failure_message_for_should do |actual|
      # Get the options from the matcher object
      opts = matcher.instance_eval { @opts }

      # Set these to nil; we'll set them in a moment
      fail_node1 = nil
      fail_node2 = nil

      # To figure out which node caused the failure, we'll need to
      # iterate over the nodes a second time
      EquivalentXml.equivalent?(actual, expected, opts) do |node1, node2, result|
        if not result and not fail_node1 then
          # Store the first failed node
          fail_node1 = node1
          fail_node2 = node2
        end
        result
      end

      # Lastly, generate a string for the failure
      [ 'expected:', expected.to_s,
        'got:', actual.to_s,
        'first failure at:', fail_node1.to_s,
        'should have been:', fail_node2.to_s,
      ].join("\n")
    end

    # Return the newly modified matcher object
    return matcher
  end
end

