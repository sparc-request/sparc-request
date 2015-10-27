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

require 'epic_interface'
require 'fake_epic_soap_server'
require 'rails_helper'

def strip_xml_whitespace!(root)
  root.xpath('//text()').each do |n|
    if n.content =~ /^\s+$/ then
      # whitespace only
      n.remove
    end
  end

  return root
end

RSpec.describe EpicInterface do
  server = nil
  port = nil
  thread = nil

  # This array holds the messages received by the epic interface.
  epic_received = [ ]

  # This array holds scripted results for the epic interface (tells the
  # interface how to respond to soap actions).
  epic_results = [ ]

  # Start up a web server with a soap endpoint for the fake epic
  # interface; this server will stay running for all the tests in this
  # block.
  before :all do
    require 'webrick'
    server = FakeEpicServer.new(
        Port: 0,               # automatically determine port
        Logger: Rails.logger,  # send regular log to rails
        AccessLog: [ ],        # disable access log
        FakeEpicServlet: {
          keep_received: true,
          received: epic_received,
          results: epic_results
        })
    thread = Thread.new { server.start }
    timeout(10) { while server.status != :Running; end }
  end

  # Shut down the server when we're done.
  after :all do
    server.shutdown
    thread.join
  end

  # Clear out the received messages and the scripted results before the
  # start of every test.
  before :each do
    epic_received.clear
    epic_results.clear
  end

  let!(:epic_interface) {
    EpicInterface.new(
        'wsdl' => "http://localhost:#{server.port}/wsdl",
        'study_root' => '1.2.3.4')
  }

  let!(:study) {
    human_subjects_info = build(:human_subjects_info, pro_number: nil, hr_number: nil)
    investigational_products_info = build(:investigational_products_info, ide_number: nil)
    study = build(:study, human_subjects_info: human_subjects_info, investigational_products_info: investigational_products_info)
    study.save(validate: false)
    study
  }

  let!(:provider) {
    create(
      :provider,
      parent_id: nil,
      name: 'South Carolina Clinical and Translational Institute (SCTR)',
      order: 1,
      css_class: 'blue-provider',
      abbreviation: 'SCTR1',
      process_ssrs: 0,
      is_available: 1)
  }

  let!(:program) {
    create(
        :program,
        type: 'Program',
        parent_id: provider.id,
        name: 'A program',
        order: 1,
        abbreviation: 'PRGM',
        process_ssrs:  0,
        is_available: 1)
  }

  describe 'send_study_creation' do
    it 'should work (smoke test)' do
      epic_interface.send_study_creation(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="STUDY#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="STUDY#{study.id}"/>
              <title>#{study.epic_title}</title>
              <text>#{study.brief_description}</text>
              <subjectOf typeCode="SUBJ">
                <studyCharacteristic classCode="OBS" moodCode="EVN">
                  <code code="RGCL3"/>
                  <value value="YES_COFC"/>
                </studyCharacteristic>
              </subjectOf>
            </plannedStudy>
          </protocolDef>
        </RetrieveProtocolDefResponse>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      # Uncomment these lines for debugging (sometimes the test output
      # doesn't give you all the information you need to figure out what
      # the difference is between actual and expected).
      # p strip_xml_whitespace!(expected.root)
      # puts ""
      # puts ""
      # p strip_xml_whitespace!(node)

      expect(node).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a PI' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "primary-pi",
          epic_access:     true, )

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="PI" />
            <value code="#{identity.netid.upcase}" codeSystem="netid" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a Billing Business Manager with Epic Access Rights' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "business-grants-manager",
          epic_access:     true, )

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="RC" />
            <value code="#{identity.netid.upcase}" codeSystem="netid" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a Co Investigator with Epic Access Rights' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "co-investigator",
          epic_access:     true, )

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="OP" />
            <value code="#{identity.netid.upcase}" codeSystem="netid" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a Research Nurse with Epic Access Rights' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "research-nurse",
          epic_access:     true, )

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="N" />
            <value code="#{identity.netid.upcase}" codeSystem="netid" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a Graduate Research Assistant with Epic Access Rights' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "grad-research-assistant",
          epic_access:     true, )

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="SC" />
            <value code="#{identity.netid.upcase}" codeSystem="netid" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should not emit a subjectOf for a Billing Business Manager without Epic Access Rights' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "business-grants-manager",
          epic_access:     false, )

      epic_interface.send_study_creation(study)

      xml = <<-END
          <subjectOf typeCode="SUBJ"
                    xmlns='urn:hl7-org:v3'
                    xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <studyCharacteristic classCode="OBS" moodCode="EVN">
              <code code="RGCL3"/>
              <value value="YES_COFC"/>
            </studyCharacteristic>
          </subjectOf>
        END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a pro number' do
      study.human_subjects_info.update_attributes(pro_number: '1234')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="IRB" />
            <value value="1234" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for an hr number' do
      study.human_subjects_info.update_attributes(hr_number: '5678')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="IRB" />
            <value value="5678" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for an nct number' do
      study.human_subjects_info.update_attributes(nct_number: '12345678')
      study.research_types_info.update_attributes(human_subjects: true)

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="NCT" />
            <value value="12345678" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for an ide number' do
      study.investigational_products_info.update_attributes(ide_number: '12345678')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="RGFT2" />
            <value value="12345678" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      node.should be_equivalent_to(expected)
    end

    it 'should emit a subjectOf for a pro number if the study has both a pro number and an hr number' do
      study.human_subjects_info.update_attributes(pro_number: '1234')
      study.human_subjects_info.update_attributes(hr_number: '5678')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="IRB" />
            <value value="1234" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    describe 'emitting a subjectOf for a study type' do
      it 'should handle nils for questions 2, 3, and 4' do
        STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
          StudyTypeQuestion.create(order: index + 1, question: stq)
        end
        answers = [true, true, true, nil, nil, nil]
        stq_ids = StudyTypeQuestion.all.map(&:id)
        stq_ids.each_with_index do |id, index|
          StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: id, answer: answers[index])
        end

        epic_interface.send_study_creation(study)

        xml = <<-END
          <subjectOf typeCode="SUBJ"
                    xmlns='urn:hl7-org:v3'
                    xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <studyCharacteristic classCode="OBS" moodCode="EVN">
              <code code="RGCL3"/>
              <value value="YES_COFC"/>
            </studyCharacteristic>
          </subjectOf>
        END

        expected = Nokogiri::XML(xml)

        node = epic_received[0].xpath(
        '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
        'env' => 'http://www.w3.org/2003/05/soap-envelope',
        'rpe' => 'urn:ihe:qrph:rpe:2009',
        'hl7' => 'urn:hl7-org:v3')

        expect(node[0]).to be_equivalent_to(expected.root)
      end

      it 'should handle answering all questions' do
        STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
          StudyTypeQuestion.create(order: index + 1, question: stq)
        end
        answers = [true, false, false, true, false, true]
        stq_ids = StudyTypeQuestion.all.map(&:id)
        stq_ids.each_with_index do |id, index|
          StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: id, answer: answers[index])
        end

        epic_interface.send_study_creation(study)

        xml = <<-END
          <subjectOf typeCode="SUBJ"
                      xmlns='urn:hl7-org:v3'
                      xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <studyCharacteristic classCode="OBS" moodCode="EVN">
              <code code="STUDYTYPE" />
              <value value="8" />
            </studyCharacteristic>
          </subjectOf>
        END

        expected = Nokogiri::XML(xml)

        node = epic_received[0].xpath(
        '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
        'env' => 'http://www.w3.org/2003/05/soap-envelope',
        'rpe' => 'urn:ihe:qrph:rpe:2009',
        'hl7' => 'urn:hl7-org:v3')

        expect(node[0]).to be_equivalent_to(expected.root)
      end

      it 'should handle answering all questions' do
        STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
          StudyTypeQuestion.create(order: index + 1, question: stq)
        end
        answers = [true, true, false, true, false, true]
        stq_ids = StudyTypeQuestion.all.map(&:id)
        stq_ids.each_with_index do |id, index|
          StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: id, answer: answers[index])
        end

        epic_interface.send_study_creation(study)

        xml = <<-END
          <subjectOf typeCode="SUBJ"
                    xmlns='urn:hl7-org:v3'
                    xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <studyCharacteristic classCode="OBS" moodCode="EVN">
              <code code="RGCL3"/>
              <value value="YES_COFC"/>
            </studyCharacteristic>
          </subjectOf>
        END

        expected = Nokogiri::XML(xml)

        node = epic_received[0].xpath(
        '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
        'env' => 'http://www.w3.org/2003/05/soap-envelope',
        'rpe' => 'urn:ihe:qrph:rpe:2009',
        'hl7' => 'urn:hl7-org:v3')

        expect(node[0]).to be_equivalent_to(expected.root)
      end

      it 'should handle nils for questions 1b and 1c' do
        STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
          StudyTypeQuestion.create(order: index + 1, question: stq)
        end
        answers = [false, nil, nil, false, true, true]
        stq_ids = StudyTypeQuestion.all.map(&:id)
        stq_ids.each_with_index do |id, index|
          StudyTypeAnswer.create(protocol_id: study.id, study_type_question_id: id, answer: answers[index])
        end

        epic_interface.send_study_creation(study)

        xml = <<-END
          <subjectOf typeCode="SUBJ"
                      xmlns='urn:hl7-org:v3'
                      xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <studyCharacteristic classCode="OBS" moodCode="EVN">
              <code code="STUDYTYPE" />
              <value value="11" />
            </studyCharacteristic>
          </subjectOf>
        END

        expected = Nokogiri::XML(xml)

        node = epic_received[0].xpath(
        '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
        'env' => 'http://www.w3.org/2003/05/soap-envelope',
        'rpe' => 'urn:ihe:qrph:rpe:2009',
        'hl7' => 'urn:hl7-org:v3')

        expect(node[0]).to be_equivalent_to(expected.root)
      end
    end


    it 'should emit a subjectOf for the category grouper GOV if its funding source is not industry' do
      study.update_attributes(funding_source: 'college')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="RGCL1" />
            <value value="GOV" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for the category grouper CORP if its funding source is industry' do
      study.update_attributes(funding_source: 'industry')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="RGCL1" />
            <value value="CORP" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for the category grouper GOV if its potential funding source is other' do
      study.update_attributes(potential_funding_source: 'other')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="RGCL1" />
            <value value="GOV" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node[0]).to be_equivalent_to(expected.root)
    end

  end # send_study_creation

  describe 'send_billing_calendar' do
    before :each do
      study.update_attributes(start_date: Time.now, end_date: Time.now + 10.days)
    end

    it 'should work (smoke test)' do
      epic_interface.send_billing_calendar(study)

      # With no line items, this message turns out to be the same as the
      # base study creation message
      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="STUDY#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="STUDY#{study.id}"/>
              <title>#{study.epic_title}</title>
              <text>#{study.brief_description}</text>
            </plannedStudy>
          </protocolDef>
        </RetrieveProtocolDefResponse>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node).to be_equivalent_to(expected.root)
    end

    it 'should not send PI or SC' do
      identity = create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "primary-pi")

      epic_interface.send_billing_calendar(study)

      # With no line items, this message turns out to be the same as the
      # base study creation message
      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="STUDY#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="STUDY#{study.id}"/>
              <title>#{study.epic_title}</title>
              <text>#{study.brief_description}</text>
            </plannedStudy>
          </protocolDef>
        </RetrieveProtocolDefResponse>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node).to be_equivalent_to(expected.root)
    end

    it 'should send an arm as a cell' do
      service_request = FactoryGirl.create(:service_request_without_validations,
                                            protocol: study,
                                            status: 'draft')

      arm1 = create(
          :arm,
          name: 'Arm',
          protocol: study,
          visit_count: 10,
          subject_count: 2)

      epic_interface.send_billing_calendar(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="STUDY#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="STUDY#{study.id}"/>
              <title>#{study.epic_title}</title>
              <text>#{study.brief_description}</text>

              <component4 typeCode="COMP">
                <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                  <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm1.id}" />
                  <title>Arm</title>
                  <code code="CELL" codeSystem="n/a" />

                  <component1 typeCode="COMP">
                    <sequenceNumber value="1" />
                    <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                      <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm1.id}.CYCLE1" />
                      <title>Cycle 1</title>
                      <code code="CYCLE" codeSystem="n/a" />
                      <effectiveTime>
                        <low value="#{epic_interface.relative_date(0, study.start_date)}"/>
                        <high value="#{epic_interface.relative_date(0, study.start_date)}"/>
                      </effectiveTime>
                    </timePointEventDefinition>
                  </component1>

                </timePointEventDefinition>
              </component4>
            </plannedStudy>

          </protocolDef>
        </RetrieveProtocolDefResponse>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node).to be_equivalent_to(expected.root)
    end

    it 'should send two arms as two cells' do
      service_request = FactoryGirl.create(:service_request_without_validations,
                                            protocol: study,
                                            status: 'draft')

      arm1 = create(
          :arm,
          name: 'Arm 1',
          protocol: study,
          visit_count: 10,
          subject_count: 2)

      arm2 = create(
          :arm,
          name: 'Arm 2',
          protocol: study,
          visit_count: 10,
          subject_count: 2)

      epic_interface.send_billing_calendar(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="STUDY#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="STUDY#{study.id}"/>
              <title>#{study.epic_title}</title>
              <text>#{study.brief_description}</text>

              <component4 typeCode="COMP" xmlns="urn:hl7-org:v3" >
                <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                  <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm1.id}" />
                  <title>Arm 1</title>
                  <code code="CELL" codeSystem="n/a" />

                  <component1 typeCode="COMP">
                    <sequenceNumber value="1" />
                    <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                      <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm1.id}.CYCLE1" />
                      <title>Cycle 1</title>
                      <code code="CYCLE" codeSystem="n/a" />
                      <effectiveTime>
                        <low value="#{epic_interface.relative_date(0, study.start_date)}"/>
                        <high value="#{epic_interface.relative_date(0, study.start_date)}"/>
                      </effectiveTime>
                    </timePointEventDefinition>
                  </component1>

                </timePointEventDefinition>
              </component4>

              <component4 typeCode="COMP" xmlns="urn:hl7-org:v3" >
                <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                  <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm2.id}" />
                  <title>Arm 2</title>
                  <code code="CELL" codeSystem="n/a" />

                  <component1 typeCode="COMP">
                    <sequenceNumber value="2" />
                    <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                      <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm2.id}.CYCLE1" />
                      <title>Cycle 1</title>
                      <code code="CYCLE" codeSystem="n/a" />
                      <effectiveTime>
                        <low value="#{epic_interface.relative_date(0, study.start_date)}"/>
                        <high value="#{epic_interface.relative_date(0, study.start_date)}"/>
                      </effectiveTime>
                    </timePointEventDefinition>
                  </component1>

                </timePointEventDefinition>
              </component4>

            </plannedStudy>

          </protocolDef>
        </RetrieveProtocolDefResponse>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      expect(node).to be_equivalent_to(expected.root).respecting_element_order
    end

    context 'with line items' do

      let!(:service_request) {
        FactoryGirl.create(:service_request_without_validations,
                            protocol: study,
                            status: 'submitted')
      }

      let!(:sub_service_request) {
        create(
            :sub_service_request,
            ssr_id: '0001',
            service_request: service_request,
            organization: program,
            status: 'submitted')
      }

      let!(:service) {
        create(
            :service,
            organization: program,
            name: 'A service')
      }

      let!(:line_item) {
        create(
            :line_item,
            service_request: service_request,
            service: service,
            sub_service_request: sub_service_request,
            quantity: 5,
            units_per_quantity: 1)
      }

      it 'should not send line items that are not part of an arm' do
        epic_interface.send_billing_calendar(study)

        # With no line items, this message turns out to be the same as the
        # base study creation message
        xml = <<-END
          <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
            <query root="1.2.3.4" extension="STUDY#{study.id}"/>
            <protocolDef>
              <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                <id root="1.2.3.4" extension="STUDY#{study.id}"/>
                <title>#{study.epic_title}</title>
                <text>#{study.brief_description}</text>
              </plannedStudy>
            </protocolDef>
          </RetrieveProtocolDefResponse>
        END

        expected = Nokogiri::XML(xml)

        node = epic_received[0].xpath(
            '//env:Body/rpe:RetrieveProtocolDefResponse',
            'env' => 'http://www.w3.org/2003/05/soap-envelope',
            'rpe' => 'urn:ihe:qrph:rpe:2009',
            'hl7' => 'urn:hl7-org:v3')

        expect(node).to be_equivalent_to(expected.root)
      end

      context 'CPT codes' do
        let!(:arm) {
          create(
              :arm,
              protocol: study,
              name: 'Arm 1',
              visit_count: 1,
              subject_count: 1)
        }

        let!(:visit_group) {
          create(
              :visit_group,
              arm: arm,
              day: -1)
        }

        # TODO: Test CPT Code
        it 'should send pppv line items with only CPT codes' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)
          service.update_attributes(cpt_code: 4321, send_to_epic: true)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window_before, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window_after, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="STUDY#{study.id}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="STUDY#{study.id}"/>
                 <title>#{study.epic_title}</title>
                 <text>#{study.brief_description}</text>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}"/>
                     <title>#{arm.name}</title>
                     <code code="CELL" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <sequenceNumber value="1"/>
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1"/>
                         <title>Cycle 1</title>
                         <code code="CYCLE" codeSystem="n/a"/>
                         <effectiveTime>
                           <low value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                           <high value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                         </effectiveTime>
                         <component1 typeCode="COMP">
                           <sequenceNumber value="1"/>
                           <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                             <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                             <title>#{visit_group.name}</title>
                           </timePointEventDefinition>
                         </component1>
                       </timePointEventDefinition>
                     </component1>
                   </timePointEventDefinition>
                 </component4>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                     <title>#{visit_group.name}</title>
                     <code code="VISIT" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}.PROC#{line_item.id}"/>
                         <code code="PROC" codeSystem="SPARCCPT"/>
                         <component2 typeCode="COMP">
                           <procedure classCode="PROC" moodCode="EVN">
                             <code code="4321" codeSystem="SPARCCPT"/>
                           </procedure>
                         </component2>
                       </timePointEventDefinition>
                     </component1>
                     <component2 typeCode="COMP">
                       <encounter classCode="ENC" moodCode="DEF">
                         <effectiveTime>
                           <low value="#{low}"/>
                           <high value="#{high}"/>
                         </effectiveTime>
                         <activityTime value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                       </encounter>
                     </component2>
                   </timePointEventDefinition>
                 </component4>
               </plannedStudy>
             </protocolDef>
            </RetrieveProtocolDefResponse>
          END

          expected = Nokogiri::XML(xml)

          node = epic_received[0].xpath(
              '//env:Body/rpe:RetrieveProtocolDefResponse',
              'env' => 'http://www.w3.org/2003/05/soap-envelope',
              'rpe' => 'urn:ihe:qrph:rpe:2009',
              'hl7' => 'urn:hl7-org:v3')

          expect(node).to be_equivalent_to(expected.root)
        end

        it 'should send pppv line items with the CPT code if it also has a Charge code' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)
          service.update_attributes(cpt_code: 4321, send_to_epic: true, charge_code: 1234)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window_before, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window_after, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="STUDY#{study.id}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="STUDY#{study.id}"/>
                 <title>#{study.epic_title}</title>
                 <text>#{study.brief_description}</text>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}"/>
                     <title>#{arm.name}</title>
                     <code code="CELL" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <sequenceNumber value="1"/>
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1"/>
                         <title>Cycle 1</title>
                         <code code="CYCLE" codeSystem="n/a"/>
                         <effectiveTime>
                           <low value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                           <high value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                         </effectiveTime>
                         <component1 typeCode="COMP">
                           <sequenceNumber value="1"/>
                           <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                             <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                             <title>#{visit_group.name}</title>
                           </timePointEventDefinition>
                         </component1>
                       </timePointEventDefinition>
                     </component1>
                   </timePointEventDefinition>
                 </component4>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                     <title>#{visit_group.name}</title>
                     <code code="VISIT" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}.PROC#{line_item.id}"/>
                         <code code="PROC" codeSystem="SPARCCPT"/>
                         <component2 typeCode="COMP">
                           <procedure classCode="PROC" moodCode="EVN">
                             <code code="4321" codeSystem="SPARCCPT"/>
                           </procedure>
                         </component2>
                       </timePointEventDefinition>
                     </component1>
                     <component2 typeCode="COMP">
                       <encounter classCode="ENC" moodCode="DEF">
                         <effectiveTime>
                           <low value="#{low}"/>
                           <high value="#{high}"/>
                         </effectiveTime>
                         <activityTime value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                       </encounter>
                     </component2>
                   </timePointEventDefinition>
                 </component4>
               </plannedStudy>
             </protocolDef>
            </RetrieveProtocolDefResponse>
          END

          expected = Nokogiri::XML(xml)

          node = epic_received[0].xpath(
              '//env:Body/rpe:RetrieveProtocolDefResponse',
              'env' => 'http://www.w3.org/2003/05/soap-envelope',
              'rpe' => 'urn:ihe:qrph:rpe:2009',
              'hl7' => 'urn:hl7-org:v3')

          expect(node).to be_equivalent_to(expected.root)
        end

        it 'should send pppv line items with only Charge codes' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)
          service.update_attributes(charge_code: 4321, send_to_epic: true)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window_before, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window_after, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="STUDY#{study.id}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="STUDY#{study.id}"/>
                 <title>#{study.epic_title}</title>
                 <text>#{study.brief_description}</text>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}"/>
                     <title>#{arm.name}</title>
                     <code code="CELL" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <sequenceNumber value="1"/>
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1"/>
                         <title>Cycle 1</title>
                         <code code="CYCLE" codeSystem="n/a"/>
                         <effectiveTime>
                           <low value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                           <high value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                         </effectiveTime>
                         <component1 typeCode="COMP">
                           <sequenceNumber value="1"/>
                           <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                             <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                             <title>#{visit_group.name}</title>
                           </timePointEventDefinition>
                         </component1>
                       </timePointEventDefinition>
                     </component1>
                   </timePointEventDefinition>
                 </component4>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                     <title>#{visit_group.name}</title>
                     <code code="VISIT" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}.PROC#{line_item.id}"/>
                         <code code="PROC" codeSystem="SPARCCPT"/>
                         <component2 typeCode="COMP">
                           <procedure classCode="PROC" moodCode="EVN">
                             <code code="4321" codeSystem="SPARCCPT"/>
                           </procedure>
                         </component2>
                       </timePointEventDefinition>
                     </component1>
                     <component2 typeCode="COMP">
                       <encounter classCode="ENC" moodCode="DEF">
                         <effectiveTime>
                           <low value="#{low}"/>
                           <high value="#{high}"/>
                         </effectiveTime>
                         <activityTime value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                       </encounter>
                     </component2>
                   </timePointEventDefinition>
                 </component4>
               </plannedStudy>
             </protocolDef>
            </RetrieveProtocolDefResponse>
          END

          expected = Nokogiri::XML(xml)

          node = epic_received[0].xpath(
              '//env:Body/rpe:RetrieveProtocolDefResponse',
              'env' => 'http://www.w3.org/2003/05/soap-envelope',
              'rpe' => 'urn:ihe:qrph:rpe:2009',
              'hl7' => 'urn:hl7-org:v3')

          expect(node).to be_equivalent_to(expected.root)
        end

        # TODO: Test no CPT Code.
        it 'should not send pppv line items without a CPT code or a Charge code' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window_before, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window_after, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="STUDY#{study.id}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="STUDY#{study.id}"/>
                 <title>#{study.epic_title}</title>
                 <text>#{study.brief_description}</text>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}"/>
                     <title>#{arm.name}</title>
                     <code code="CELL" codeSystem="n/a"/>
                     <component1 typeCode="COMP">
                       <sequenceNumber value="1"/>
                       <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                         <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1"/>
                         <title>Cycle 1</title>
                         <code code="CYCLE" codeSystem="n/a"/>
                         <effectiveTime>
                           <low value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                           <high value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                         </effectiveTime>
                         <component1 typeCode="COMP">
                           <sequenceNumber value="1"/>
                           <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                             <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                             <title>#{visit_group.name}</title>
                           </timePointEventDefinition>
                         </component1>
                       </timePointEventDefinition>
                     </component1>
                   </timePointEventDefinition>
                 </component4>
                 <component4 typeCode="COMP">
                   <timePointEventDefinition classCode="CTTEVENT" moodCode="DEF">
                     <id root="1.2.3.4" extension="STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.id}"/>
                     <title>#{visit_group.name}</title>
                     <code code="VISIT" codeSystem="n/a"/>
                     <component2 typeCode="COMP">
                       <encounter classCode="ENC" moodCode="DEF">
                         <effectiveTime>
                           <low value="#{low}"/>
                           <high value="#{high}"/>
                         </effectiveTime>
                         <activityTime value="#{epic_interface.relative_date(visit_group.day, study.start_date)}"/>
                       </encounter>
                     </component2>
                   </timePointEventDefinition>
                 </component4>
               </plannedStudy>
             </protocolDef>
            </RetrieveProtocolDefResponse>
          END

          expected = Nokogiri::XML(xml)

          node = epic_received[0].xpath(
              '//env:Body/rpe:RetrieveProtocolDefResponse',
              'env' => 'http://www.w3.org/2003/05/soap-envelope',
              'rpe' => 'urn:ihe:qrph:rpe:2009',
              'hl7' => 'urn:hl7-org:v3')

          expect(node).to be_equivalent_to(expected.root)
        end
      end
    end

    # TODO: add a test for when we have more than one pppv line item
    # TODO: add a test for when we have more than one service request
    # TODO: add a test for visit group window
  end

  describe 'send_study' do
    # TODO: add tests for the full study message
  end

end
