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

require 'epic_interface'

# Keeps track of the messages that the fake epic server received in test
# mode (see EPIC_RECEIVED, below).
class EpicReceivedMessages < Array
  attr_accessor :keep

  def initialize
    super
    @keep = false
  end
  
  def <<(body)
    super(body) if @keep
  end
end

# Start the fake epic server (used in test mode)
def start_fake_epic_server(epic_received, epic_results)
  require 'webrick'
  require 'fake_epic_soap_server'

  # TODO: duplicated with spec/extensions/epic_interface_spec.rb
  Rails.logger.info("Starting fake epic server")
  server = FakeEpicServer.new(
      Port: 0,                # automatically determine port
      Logger: Rails.logger,   # send regular log to rails
      AccessLog: [ ],         # disable access log
      FakeEpicServlet: {
        keep_received: true,
        received: epic_received,
        results: epic_results,
      })
  thread = Thread.new { server.start }
  timeout(10) { while server.status != :Running; end }
  at_exit { server.shutdown; thread.join }

  return server
end

# Load the config file
epic_config = YAML.load_file(Rails.root.join('config', 'epic.yml'))[Rails.env]

# If we are in test mode, start a fake epic interconnect server
if epic_config['test_mode'] then
  # To be used by the tests to validate what was sent in to the server
  EPIC_RECEIVED = EpicReceivedMessages.new

  # To be used by the tests to control what the server sends back
  EPIC_RESULTS = [ ]

  # The fake epic server itself
  FAKE_EPIC_SERVER = start_fake_epic_server(EPIC_RECEIVED, EPIC_RESULTS)
  epic_config['wsdl'] = "http://localhost:#{FAKE_EPIC_SERVER.port}/wsdl"
  epic_config['study_root'] ||= '1.2.3.4'
end

# Finally, construct the interface itself
Rails.logger.info("Creating epic interface")
EPIC_INTERFACE = EpicInterface.new(epic_config)

