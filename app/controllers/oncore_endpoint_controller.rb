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

class OncoreEndpointController < ApplicationController
  # All of the following nested classes are used in order to avoid a duplicate key error from WashOut.
  # If args contains an element within the same element, there will be an error when generating the WSDL.
  # For example:
  # This one gives a dupicate error              |   This one DOES NOT result in a duplicate error
  # :args => {                                   |   :args => {
  #   :element => {                              |     :element => {
  #     :thing => :string,                       |       :thing => :string,
  #     :element => { :@attribute => :string }   |       :element => Element #Element is a custom WashOut::Type class
  #   }                                          |     }
  # }                                            |   }
  class Id < WashOut::Type
    map :@extension => :string, :@root => :string
  end

  class Code < WashOut::Type
    map :@code => :string, :@codeSystem => :string
  end

  class EffectiveTime < WashOut::Type
    map :low => { :@value => :string },
        :high => { :@value => :string }
  end

  class SequenceNumber < WashOut::Type
    map :@value => :string
  end

  class TPED < WashOut::Type
    #TPED = TimePointEventDefinition
    map :id => Id,
        :title => :string
  end

  class Component1 < WashOut::Type
    # Base component1 element, no other components nested inside
    map :sequenceNumber => SequenceNumber,
        :timePointEventDefinition => TPED
  end

  class Component2Procedure < WashOut::Type
    # component2 elements with nested procedure element
    map :procedure => {
          :code => Code
        }
  end

  class Component2Encounter < WashOut::Type
    # component2 elements with nested encounter element
    map :encounter => {
          :effectiveTime => EffectiveTime,
          :activityTime => { :@value => :string }
        }
  end

  class Component2Arm < WashOut::Type
    # component2 elements with nested arm element
    map :arm => {
          :id => { :@extension => :string },
          :title => :string
        }
  end

  class TPEDComponent1 < WashOut::Type
    # Complex type structure for TPED with a component1 nested inside
    map :id => Id,
        :title => :string,
        :code => Code,

        :component1 => [Component1],

        :component2 => Component2Procedure,

        :effectiveTime => EffectiveTime

  end

  #############################################
  #   SOAP Endpoint for OnCore RPE messages   #
  #############################################

  soap_service namespace: 'urn:ihe:qrph:rpe:2009', camelize_wsdl: :lower
               # might need to camelize wsdl for OnCore since I'm pretty sure they use Java and camelcase

  soap_action "RetrieveProtocolDefResponse",
    :args => {
      :protocolDef => {
        :plannedStudy => {
          :id => Id,
          :title => :string,
          :text => :string,

          :subjectOf => [{
            :studyCharacteristic => {
              :code => Code,
              :value => { :@value => :string, :@code => :string, :@codeSystem => :string }
            }
          }],

          :component4 => [{
            :timePointEventDefinition => {
              :id => Id,
              :title => :string,
              :code => Code,

              :component1 => [{
                :sequenceNumber => SequenceNumber,
                :timePointEventDefinition => TPEDComponent1
              }],

              :component2 => Component2Encounter

            }
          }],

          :component2 => [Component2Arm]

        }
      }
    },

    :return => { 'responseCode' => :string },
    :to     => :retrieve_protocol_def
  def retrieve_protocol_def
    # === Logging and testing info =============================
    # Pretty print the params:
    puts JSON.pretty_generate(oncore_endpoint_params.to_h)
    # Print the params to a specific OnCore log
    print_params_to_log
    # ==========================================================

    # return proper SOAP response
    # PROTOCOL_RECEIVED might be different if an error occurs
    render :soap => { 'responseCode' => 'PROTOCOL_RECEIVED' }
  end

  private

  def find_protocol_by_rmid
    rmid = oncore_endpoint_params[:plannedStudy][:id][:extension] #protocol RMID as a string
    return Protocol.find_by(research_master_id: rmid)
  end

  def print_params_to_log
    logfile = File.join(Rails.root, '/log/', "OnCore-#{Rails.env}.log")
    logger = ActiveSupport::Logger.new(logfile)
    logger.info "\n----------------------------------------------------------------------------------"
    logger.info "RetrieveProtocolDefResponse request - #{DateTime.now}"
    logger.info "Params received by OncoreEndpointController:"
    logger.info JSON.pretty_generate(oncore_endpoint_params.to_h)
    logger.info "----------------------------------------------------------------------------------\n"
  end

  def oncore_endpoint_params
    params.require(:protocolDef).permit!
  end
end
