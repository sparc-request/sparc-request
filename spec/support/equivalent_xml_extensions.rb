# Copyright © 2011 MUSC Foundation for Research Development
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

