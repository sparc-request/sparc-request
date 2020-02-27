# Copyright © 2011-2019 MUSC Foundation for Research Development
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

class ProtocolSoapEndpointsController < ApplicationController
  # SOAP Endpoint for OnCore RPE messages
  soap_service namespace: 'urn:WashOut'

  soap_action "RetrieveProtocolDefResponse",
    :args => {
      :protocolDef => {
        :plannedStudy => {
          :id => { :@extension => :string, :@root => :string },
          :title => :string,
          :text => :string,

          :subjectOf => [{
            :studyCharacteristic => {
              :code => { :@code => :string },
              :value => { :@value => :string, :@code => :string, :@codeSystem => :string }
            }
          }],

          :component4 => [{
            :timePointEventDefinition => {
              :id => { :@extension => :string, :@root => :string },
              :title => :string,
              :code => { :@code => :string, :@codeSystem => :string },

              :component1 => [{
                :sequenceNumber => { :@value => :string },
                :timePointEventDefinition => {
                  :id => { :@extension => :string, :@root => :string },
                  :title => :string,
                  :code => { :@code => :string, :@codeSystem => :string },

                  :component1 => [{
                    :sequenceNumber => { :@value => :string },
                    :timePointEventDefinition => {
                      :id => { :@extension => :string, :@root => :string },
                      :title => :string
                    },
                  }],

                  :component2 => {
                    :procedure => {
                      :code => { :@code => :string, :@codeSystem => :string }
                    }
                  },

                  :effectiveTime => {
                    :low => { :@value => :string },
                    :high => { :@value => :string }
                  }
                }
              }],

              :component2 => {
                :encounter => {
                  :effectiveTime => {
                    :low => { :@value => :string },
                    :high => { :@value => :string }
                  },
                  :activityTime => { :@value => :string }
                }
              }

            }
          }],

          :component2 => [{
            :arm => {
              :id => { :@extension => :string },
              :title => :string
            }
          }]

        }
      }
    },

    :return => nil,
    :to     => :retrieve_protocol_def
  def retrieve_protocol_def
    # Pretty print the params:
    puts JSON.pretty_generate(protocol_soap_endpoint_params.to_h)
    # binding.pry
    render :soap => nil
  end

  private

  def protocol_soap_endpoint_params
    params.require(:protocolDef).permit!
  end
end
