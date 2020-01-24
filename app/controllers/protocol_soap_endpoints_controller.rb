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
              :args   => :string,
              :return => nil,
              :to     => :retrieve_protocol_def
  def retrieve_protocol_def
    Rails.logger.info "\n\n\n\n***************\n\n\n\n\n#{params.inspect}\n\n\n\n***************\n\n\n\n\n"
    render :soap => nil
  end

  def protocol_soap_endpoint_params
    params.require(:protocol_soap_endpoint).permit!
  end

  # example message:

# <query root="1.2.5.2.3.4" extension="STUDY13481"/>
# <protocolDef>
#   <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
#     <id root="1.2.5.2.3.4" extension="STUDY13481"/>
#     <title>Test Epic Error Handling - Test Epic Error Handling</title>
#     <text/>
#     <subjectOf typeCode="SUBJ">
#       <studyCharacteristic classCode="OBS" moodCode="EVN">
#         <code code="PI"/>
#         <value code="WEH6" codeSystem="netid"/>
#       </studyCharacteristic>
#     </subjectOf>
#     <subjectOf typeCode="SUBJ">
#       <studyCharacteristic classCode="OBS" moodCode="EVN">
#         <code code="NCT"/>
#         <value value="12345679"/>
#       </studyCharacteristic>
#     </subjectOf>
#     <subjectOf typeCode="SUBJ">
#       <studyCharacteristic classCode="OBS" moodCode="EVN">
#         <code code="RGCL1"/>
#         <value value="GOV"/>
#       </studyCharacteristic>
#     </subjectOf>
#     <subjectOf typeCode="SUBJ">
#       <studyCharacteristic classCode="OBS" moodCode="EVN">
#         <code code="STUDYTYPE"/>
#         <value value="1"/>
#       </studyCharacteristic>
#     </subjectOf>
#     <subjectOf typeCode="SUBJ">
#       <studyCharacteristic classCode="OBS" moodCode="EVN">
#         <code code="RGCL3"/>
#         <value value="YES_COFC"/>
#       </studyCharacteristic>
#     </subjectOf>
#     <component4 typeCode="COMP">
#       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
#         <id root="1.2.5.2.3.4" extension="STUDY13481.ARM19648"/>
#         <title>Screening Phase</title>
#         <code code="CELL" codeSystem="n/a"/>
#         <component1 typeCode="COMP">
#           <sequenceNumber value="1"/>
#           <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
#             <id root="1.2.5.2.3.4" extension="STUDY13481.ARM19648.CYCLE1"/>
#             <title>Cycle 1</title>
#             <code code="CYCLE" codeSystem="n/a"/>
#             <effectiveTime>
#               <low value="20200108"/>
#               <high value="20200108"/>
#             </effectiveTime>
#             <component1 typeCode="COMP">
#               <sequenceNumber value="1"/>
#               <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
#                 <id root="1.2.5.2.3.4" extension="STUDY13481.ARM19648.CYCLE1.DAY1"/>
#                 <title>Visit 1</title>
#               </timePointEventDefinition>
#             </component1>
#           </timePointEventDefinition>
#         </component1>
#       </timePointEventDefinition>
#     </component4>
#     <component4 typeCode="COMP">
#       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
#         <id root="1.2.5.2.3.4" extension="STUDY13481.ARM19648.CYCLE1.DAY1"/>
#         <title>Visit 1</title>
#         <code code="VISIT" codeSystem="n/a"/>
#         <component2 typeCode="COMP">
#           <encounter classCode="ENC" moodCode="DEF">
#             <effectiveTime>
#               <low value="20200108"/>
#               <high value="20200108"/>
#             </effectiveTime>
#             <activityTime value="20200108"/>
#           </encounter>
#         </component2>
#       </timePointEventDefinition>
#     </component4>
#   </plannedStudy>
# </protocolDef>
end