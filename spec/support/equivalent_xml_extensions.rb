require 'equivalent-xml'
require 'tempfile'

def xmldiff_strings(str1, str2)
  file1 = nil
  file2 = nil

  file1 = Tempfile.open('str1')
  begin
    file2 = Tempfile.open('str1')
    begin
      file1.write(str1)
      file2.write(str2)
      file1.close
      file2.close
      return `xmldiff #{file1.path} #{file2.path}`
    ensure
      file2.unlink
      file2.close
    end
  ensure
    file1.unlink
    file1.close
  end
end

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
      result = [ 'expected:', expected.to_s,
        'got:', actual.to_s,
        'first failure at:', fail_node1.to_s,
        'should have been:', fail_node2.to_s,
      ]

      # Check to see if xmldiff is installed
      `which xmldiff`
      if $? == 0 then
        # If it is installed, then use it to produce a diff
        result << 'xmldiff returned:'
        result << xmldiff_strings(actual, expected)
      end

      result.join("\n") # return
    end

    # Return the newly modified matcher object
    return matcher
  end
end

