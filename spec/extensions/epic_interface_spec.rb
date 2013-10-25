require 'epic_interface'
require 'fake_epic_soap_server'
require 'spec_helper'

def strip_xml_whitespace!(root)
  root.xpath('//text()').each do |n|
    if n.content =~ /^\s+$/ then
      # whitespace only
      n.remove
    end
  end

  return root
end

describe EpicInterface do
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
    human_subjects_info = FactoryGirl.build(:human_subjects_info, pro_number: nil, hr_number: nil)
    study = FactoryGirl.build(:study, human_subjects_info: human_subjects_info)
    study.save(validate: false)
    study
  }

  let!(:program) {
    FactoryGirl.create(
        :program,
        type: 'Program',
        parent_id: nil,
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
          <query root="1.2.3.4" extension="#{study.short_title}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.short_title}"/>
              <title>#{study.title}</title>
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

      # Uncomment these lines for debugging (sometimes the test output
      # doesn't give you all the information you need to figure out what
      # the difference is between actual and expected).
      # p strip_xml_whitespace!(expected.root)
      # p strip_xml_whitespace!(node)

      node.should be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a PI' do
      identity = FactoryGirl.create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = FactoryGirl.create(
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
            <value xsi:type="CD" code="#{identity.netid.upcase}" codeSystem="netid" />
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

    it 'should emit a subjectOf for a Billing Business Manager with Epic Access Rights' do
      identity = FactoryGirl.create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = FactoryGirl.create(
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
            <code code="SC" />
            <value xsi:type="CD" code="#{identity.netid.upcase}" codeSystem="netid" />
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

    it 'should not emit a subjectOf for a Billing Business Manager without Epic Access Rights' do
      identity = FactoryGirl.create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = FactoryGirl.create(
          :project_role,
          protocol:        study,
          identity:        identity,
          project_rights:  "approve",
          role:            "business-grants-manager",
          epic_access:     false, )

      epic_interface.send_study_creation(study)

      xml = <<-END
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/rpe:protocolDef/hl7:plannedStudy/hl7:subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009',
          'hl7' => 'urn:hl7-org:v3')

      node.should be_equivalent_to(expected)
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
            <value xsi:type="ST" value="1234" />
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

    it 'should emit a subjectOf for an hr number' do
      study.human_subjects_info.update_attributes(hr_number: '5678')

      epic_interface.send_study_creation(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns='urn:hl7-org:v3'
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="IRB" />
            <value xsi:type="ST" value="5678" />
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
            <value xsi:type="ST" value="1234" />
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
          <query root="1.2.3.4" extension="#{study.short_title}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.short_title}"/>
              <title>#{study.title}</title>
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

      node.should be_equivalent_to(expected.root)
    end

    it 'should not send PI or SC' do
      identity = FactoryGirl.create(
          :identity,
          ldap_uid: 'happyhappyjoyjoy@musc.edu')

      pi_role = FactoryGirl.create(
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
          <query root="1.2.3.4" extension="#{study.short_title}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.short_title}"/>
              <title>#{study.title}</title>
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

      node.should be_equivalent_to(expected.root)
    end

    it 'should send an arm as a cell' do
      service_request = FactoryGirl.create(
          :service_request,
          protocol: study,
          status: 'draft')

      arm1 = FactoryGirl.create(
          :arm,
          name: 'Arm',
          protocol: study,
          visit_count: 10,
          subject_count: 2)

      epic_interface.send_billing_calendar(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.short_title}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.short_title}"/>
              <title>#{study.title}</title>
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

      node.should be_equivalent_to(expected.root)
    end

    it 'should send two arms as two cells' do
      service_request = FactoryGirl.create(
          :service_request,
          protocol: study,
          status: 'draft')

      arm1 = FactoryGirl.create(
          :arm,
          name: 'Arm 1',
          protocol: study,
          visit_count: 10,
          subject_count: 2)

      arm2 = FactoryGirl.create(
          :arm,
          name: 'Arm 2',
          protocol: study,
          visit_count: 10,
          subject_count: 2)

      epic_interface.send_billing_calendar(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.short_title}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.short_title}"/>
              <title>#{study.title}</title>
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

      node.should be_equivalent_to(expected.root).respecting_element_order
    end

    context 'with line items' do

      let!(:service_request) {
        FactoryGirl.create(
            :service_request,
            protocol: study,
            status: 'submitted')
      }

      let!(:sub_service_request) {
        FactoryGirl.create(
            :sub_service_request,
            ssr_id: '0001',
            service_request: service_request,
            organization: program,
            status: 'submitted')
      }

      let!(:service) {
        FactoryGirl.create(
            :service,
            organization: program,
            name: 'A service')
      }

      let!(:line_item) {
        FactoryGirl.create(
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
            <query root="1.2.3.4" extension="#{study.short_title}"/>
            <protocolDef>
              <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                <id root="1.2.3.4" extension="#{study.short_title}"/>
                <title>#{study.title}</title>
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

        node.should be_equivalent_to(expected.root)
      end

      context 'CPT and CDM codes' do
        let!(:arm) {
          FactoryGirl.create(
              :arm,
              protocol: study,
              name: 'Arm 1',
              visit_count: 1,
              subject_count: 1)
        }

        let!(:visit_group) {
          FactoryGirl.create(
              :visit_group,
              arm: arm,
              day: -1)
        }

        # TODO: Test CDM Code no CPT
        it 'should send pppv line items with only CDM codes' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)
          service.update_attributes(cdm_code: 1234, send_to_epic: true)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="#{study.short_title}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="#{study.short_title}"/>
                 <title>#{study.title}</title>
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
                         <code code="PROC" codeSystem="CDM"/>
                         <component2 typeCode="COMP">
                           <procedure classCode="PROC" moodCode="EVN">
                             <code code="1234" codeSystem="CDM"/>
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

          node.should be_equivalent_to(expected.root)
        end

        # TODO: Test CPT Code no CDM
        it 'should send pppv line items with only CPT codes' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)
          service.update_attributes(cpt_code: 4321, send_to_epic: true)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="#{study.short_title}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="#{study.short_title}"/>
                 <title>#{study.title}</title>
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
                         <code code="PROC" codeSystem="CPT"/>
                         <component2 typeCode="COMP">
                           <procedure classCode="PROC" moodCode="EVN">
                             <code code="4321" codeSystem="CPT"/>
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

          node.should be_equivalent_to(expected.root)
        end

        # TODO: Test CDM and CPT Code
        it 'should send pppv line items with either CPT or CDM codes' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)
          service.update_attributes(cpt_code: 4321,
                                    cdm_code: 1234,
                                    send_to_epic: true)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="#{study.short_title}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="#{study.short_title}"/>
                 <title>#{study.title}</title>
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
                         <code code="PROC" codeSystem="CDM"/>
                         <component2 typeCode="COMP">
                           <procedure classCode="PROC" moodCode="EVN">
                             <code code="1234" codeSystem="CDM"/>
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

          node.should be_equivalent_to(expected.root)
        end

        # TODO: Test neither CDM nor CPT Code.
        it 'should not send pppv line items without a CPT or CDM code' do
          liv = LineItemsVisit.for(arm, line_item)
          visit = Visit.for(liv, visit_group)
          visit.update_attributes(research_billing_qty: 1)

          epic_interface.send_billing_calendar(study)

          low = epic_interface.relative_date(visit_group.day - visit_group.window, study.start_date)
          high = epic_interface.relative_date(visit_group.day + visit_group.window, study.start_date)

          xml = <<-END
            <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
             <query root="1.2.3.4" extension="#{study.short_title}"/>
             <protocolDef>
               <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
                 <id root="1.2.3.4" extension="#{study.short_title}"/>
                 <title>#{study.title}</title>
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

          node.should be_equivalent_to(expected.root)
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
