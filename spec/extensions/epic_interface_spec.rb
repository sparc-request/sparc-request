require 'epic_interface'
require 'spec_helper'
require 'equivalent-xml'

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
    server = WEBrick::HTTPServer.new(
        Port: 0,               # automatically determine port
        Logger: Rails.logger,  # send regular log to rails
        AccessLog: [ ]         # disable access log
        )
    server.mount(
        '/',
        FakeEpicServlet,
        keep_received: true,
        received: epic_received,
        results: epic_results)
    port = server.config[:Port]
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
        'endpoint' => "http://localhost:#{port}/",
        'study_root' => '1.2.3.4')
  }

  let!(:study) {
    study = FactoryGirl.build(:study)
    study.save(validate: false)
    study
  }

  describe 'send_study' do
    it 'should work (smoke test)' do
      epic_interface.send_study(study)

      xml = <<-END
        <rpe:RetrieveProtocolDefResponse xmlns:rpe="urn:ihe:qrph:rpe:2009">
          <query root="1.2.3.4" extension="#{study.id}" />
          <protocolDef>
            <plannedStudy classCode='CLNTRL' moodCode='DEF'>
              <id root="1.2.3.4" extension="#{study.id}" />
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
          'rpe' => 'urn:ihe:qrph:rpe:2009')

      # p strip_xml_whitespace!(expected.root)
      # p strip_xml_whitespace!(node)

      node.should be_equivalent_to(expected.root)
    end

    it 'should emit a subjectOf for a PI' do
      identity = FactoryGirl.create(:identity)

      pi_role = FactoryGirl.create(
          :project_role,
          protocol_id:     study.id,
          identity_id:     identity.id,
          project_rights:  "approve",
          role:            "pi")

      epic_interface.send_study(study)

      xml = <<-END
        <subjectOf typeCode="SUBJ"
                   xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
          <studyCharacteristic classCode="OBS" moodCode="EVN">
            <code code="PI" />
            <value xsi:type="ST" value="#{identity.ldap_uid}" />
          </studyCharacteristic>
        </subjectOf>
      END

      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/protocolDef/plannedStudy/subjectOf',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009')

      node.should be_equivalent_to(expected)
    end
  end

end
