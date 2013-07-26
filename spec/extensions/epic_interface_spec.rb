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
    study = FactoryGirl.build(:study)
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

  describe 'send_study' do
    it 'should work (smoke test)' do
      epic_interface.send_study(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.id}"/>
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
          role:            "primary-pi")

      epic_interface.send_study(study)

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
  end

  describe 'send_billing_calendar' do
    it 'should work (smoke test)' do
      epic_interface.send_billing_calendar(study)

      # With no line items, this message turns out to be the same as the
      # base study creation message
      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.id}"/>
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
          <query root="1.2.3.4" extension="#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.id}"/>
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
          status: 'draft',
          start_date: Time.now,
          end_date: Time.now + 10.days)

      arm1 = FactoryGirl.create(
          :arm,
          name: 'Arm',
          service_request: service_request,
          visit_count: 10,
          subject_count: 2)

      epic_interface.send_billing_calendar(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.id}"/>
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
                        <low value="#{service_request.start_date.strftime('%Y%m%d')}" />
                        <high value="#{service_request.end_date.strftime('%Y%m%d')}" />
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
          status: 'draft',
          start_date: Time.now,
          end_date: Time.now + 10.days)

      arm1 = FactoryGirl.create(
          :arm,
          name: 'Arm 1',
          service_request: service_request,
          visit_count: 10,
          subject_count: 2)

      arm2 = FactoryGirl.create(
          :arm,
          name: 'Arm 2',
          service_request: service_request,
          visit_count: 10,
          subject_count: 2)

      epic_interface.send_billing_calendar(study)

      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.id}"/>
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
                        <low value="#{service_request.start_date.strftime('%Y%m%d')}" />
                        <high value="#{service_request.end_date.strftime('%Y%m%d')}" />
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
                        <low value="#{service_request.start_date.strftime('%Y%m%d')}" />
                        <high value="#{service_request.end_date.strftime('%Y%m%d')}" />
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

    it 'should not send line items that are not part of an arm' do
      service_request = FactoryGirl.create(
          :service_request,
          protocol: study,
          status: 'draft',
          start_date: Time.now,
          end_date: Time.now + 10.days)

      sub_service_request = FactoryGirl.create(
          :sub_service_request,
          ssr_id: '0001',
          service_request: service_request,
          organization: program,
          status: 'draft')

      service = FactoryGirl.create(
          :service,
          organization: program,
          name: 'A service')

      line_item = FactoryGirl.create(
          :line_item,
          service_request: service_request,
          service: service,
          sub_service_request: sub_service_request,
          quantity: 5,
          units_per_quantity: 1)

      epic_interface.send_billing_calendar(study)

      # With no line items, this message turns out to be the same as the
      # base study creation message
      xml = <<-END
        <RetrieveProtocolDefResponse xmlns="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.id}"/>
          <protocolDef>
            <plannedStudy xmlns="urn:hl7-org:v3" classCode="CLNTRL" moodCode="DEF">
              <id root="1.2.3.4" extension="#{study.id}"/>
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

    # TODO: add a test for when we have a line item
    # TODO: add a test for when we have more than one line item
    # TODO: add a test for when we have more than one service request
    # TODO: add a test for visit group window
    # TODO: add a test to ensure that we are using CDM code
    # TODO: add a test for multiple service requests
  end

end
