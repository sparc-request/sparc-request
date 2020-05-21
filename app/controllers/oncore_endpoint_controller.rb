# Copyright © 2011-2020 MUSC Foundation for Research Development
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

  soap_service namespace: 'urn:ihe:qrph:rpe:2009', camelize_wsdl: :lower, parser: :nokogiri
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

    :return => { 'tns:responseCode' => :string },
    :header_return => :string,
    :to     => :retrieve_protocol_def
  def retrieve_protocol_def
    begin
      # find the protocol
      protocol = find_valid_protocol_by_rmid

      # Don't try to build calendar information if it doesn't exist (RPE messages don't have calendar info)
      if !is_rpe_message?
        # Add arms to the protocol
        get_arms_from_cells(protocol)

        # Build out calendar info (visit groups, line items, line item visits, visits, etc.) from VISIT elements for each arm
        protocol.arms.each do |arm|
          build_calendar_info(arm)
        end
      end
    rescue Exception => e
      # Print params and exception to testing log
      print_params_to_log(e)
      # Render a SOAP fault response for exceptions instead of the default HTML response from Rails
      render_soap_error(e.message)
    else
      # Print params to testing log
      print_params_to_log
      # return PROTOCOL_RECEIVED SOAP response on successful load (they requested this solely because that's the response Epic sends)
      render :soap => { 'tns:responseCode' => 'PROTOCOL_RECEIVED' },
             :header => SecureRandom.uuid
    end
  end

  private

  def find_valid_protocol_by_rmid
    rmid = oncore_endpoint_params[:plannedStudy][:id][:extension] #protocol RMID as a string
    if !rmid.nil? && protocol = Protocol.find_by(research_master_id: rmid)
      if protocol.has_clinical_services?
        raise "Error: SPARC Protocol #{rmid} has an existing calendar and cannot be overwritten."
      else
        return protocol
      end
    else
      raise "Error: No existing SPARC Protocol with identifier #{rmid}."
    end
  end

  # Creates arms on the protocol and
  # assigns a hash with the structure { SPARC_arm_id => arm_code } since arm_code is used like an ID that isn't stored in SPARC
  def get_arms_from_cells(protocol)
    # component4 CELL elements contain arm and visit imformation including calendar and budget version.
    @arm_codes = {}
    oncore_endpoint_params[:plannedStudy][:component4].select{ |c4| c4[:timePointEventDefinition][:code][:code] == "CELL" }.each do |cell|
      arm_code = cell[:timePointEventDefinition][:id][:extension].split('.')[1]
      arm_name = cell[:timePointEventDefinition][:title].gsub(/([^A][^r][^m][^\:])+Arm\:/, '')
      # Remove bad characters from the arm name
      arm_name.gsub!(/[\[\]\*\/\\\?\:]/, '')

      calendar_version = cell[:timePointEventDefinition][:title].split(/[\s\:]/)[1] # can't do this for arm name because the name can have a :

      budget_version = cell[:timePointEventDefinition][:title].split(/[\s\:]/)[3]

      # The number of VISITS equal the number of visit groups, we can use that for the visit count
      # Visits are also listed under CELL elements but are nested under CYCLES, which have no SPARC equivalent, so VISITs are used for simplicity
      visit_count = oncore_endpoint_params[:plannedStudy][:component4].select{ |c4|
        c4[:timePointEventDefinition][:code][:code] == "VISIT" && c4[:timePointEventDefinition][:id][:extension].split('.').first == arm_code
      }.count

      if arm = protocol.arms.create(name: arm_name, subject_count: 1, visit_count: visit_count)
        @arm_codes[arm.id] = arm_code
      end
    end
  end

  def build_calendar_info(arm)
    # component4 VISIT elements contain visit group information and procedures.
    # VISITS are like visit groups and PROCS are like line item visits, including service information.
    protocol = arm.protocol
    service_request = protocol.service_requests.first

    oncore_endpoint_params[:plannedStudy][:component4].select{ |c4| 
      c4[:timePointEventDefinition][:code][:code] == "VISIT" && c4[:timePointEventDefinition][:id][:extension].split('.').first == @arm_codes[arm.id]
    }.each_with_index do |oncore_visit, position|

      if position == 0 # procedures are on VISITs, but we only need to make line items and line items visits once per arm
        # Create line items for a default placeholder service. The ID for this service is XXXXXX
        service = Service.find(41714)
        if service.nil?
          raise "Unable to find the default OnCore Push service."
        end
        service_request.create_line_items_for_service(service: service)

        # -------------------------------------------------------------------------------------
        # TODO: get the service from the procedure.
        # Code for this is temporarily removed until the Chargemaster situation can be figured out. 
        # This might need to be a conditional case where if there are no procedures, use the default service, otherwise, get the services.
        # oncore_visit[:timePointEventDefinition][:component1].select{ |c1| c1[:timePointEventDefinition][:code][:code] == "PROC" }.each do |procedure|
        #   # Get the service from the procedure.
        #   service_name = procedure[:timePointEventDefinition][:title]
        #   service_code = procedure[:timePointEventDefinition][:component2][:procedure][:code][:code] # either eap_id or cpt_code
        #   service = Service.where(name: service_name, is_available: true).merge(Service.where(cpt_code: service_code).or(Service.where(eap_id: service_code))).first

        #   if service.nil?
        #     raise "Unable to find service #{service_name} with code #{service_code}"
        #   end

        #   # For each procedure, make a line item on the protocol
        #   service_request.create_line_items_for_service(service: service)
        # end
        # -------------------------------------------------------------------------------------
      end

      # create a visit group for each VISIT
      # each VISIT should have one encounter. The encounter contains dates relative to Jan 1, 2000
        # effectiveTime = window before and after:
          # low = window before. ex) 20000327 - window before: 3
          # high = window after. ex) 20000402 - window after: 3
        # activityTime = day ex) 20000330 - day: 90
      encounter = oncore_visit[:timePointEventDefinition][:component2][:encounter]
      visit_group = arm.visit_groups[position]
      vg_name = oncore_visit[:timePointEventDefinition][:title].sub("#{@arm_codes[arm.id]}, ", "")
      day = relative_date_to_day(encounter[:activityTime][:value])
      window_before = day - relative_date_to_day(encounter[:effectiveTime][:low][:value])
      window_after = relative_date_to_day(encounter[:effectiveTime][:high][:value]) - day
      visit_group.update_attributes(name: vg_name, day: day, window_before: window_before, window_after: window_after)
    end
  end

  # Returns true if the SOAP message is an RPE message.
  # The only difference between RPE messages and CRPC messages is that CRPC messages contain calendar information (component4's)
  # and RPE messages do not have any calendar information (no component4 elements).
  def is_rpe_message?
    oncore_endpoint_params[:plannedStudy][:component4].nil?
  end

  # Returns an integer representing the number of days since Jan 1, 2000
  # Parameters:
  #   date: string date with the format "yyyymmdd" any other formats will not work.
  def relative_date_to_day(date)
    ( Date.new(2000,1,1)..Date.new(date[0..3].to_i,date[4..5].to_i,date[6..7].to_i) ).count
  end

  def print_params_to_log(e=nil)
    logfile = File.join(Rails.root, '/log/', "OnCore-#{Rails.env}.log")
    logger = ActiveSupport::Logger.new(logfile)
    logger.info "\n----------------------------------------------------------------------------------"
    logger.info "RetrieveProtocolDefResponse request ---------- Timestamp: #{DateTime.now.to_formatted_s(:long)}"
    logger.info "Params received by OncoreEndpointController:"
    logger.info JSON.pretty_generate(oncore_endpoint_params.to_h)
    unless e.nil?
      logger.info "Error:\n"
      logger.info e.message
      logger.info e.backtrace.inspect
    end
    logger.info "----------------------------------------------------------------------------------\n"
  end

  def oncore_endpoint_params
    params.require(:protocolDef).permit!
  end
end
