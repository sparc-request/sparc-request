require 'epic_interface'
require 'spec_helper'
require 'equivalent-xml'

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

  let!(:epic_interface) { EpicInterface.new('endpoint' => "http://localhost:#{port}/") }
  let!(:study) { FactoryGirl.build(:study) }

  describe 'send_study' do
    it 'should do something' do
      epic_interface.send_study(study)

      # <env:Body>
      #   <rpe:RetrieveProtocolDefResponse>
      #     <protocolDef>
      #       <query root="" extension=""/>
      #       <plannedStudy classCode="CLNTRL" moodCode="DEF">
      #         <id root="" extension=""/>
      #         <title>At nemo pariatur ducimus.</title>
      #         <text>Consequuntur tenetur praesentium esse est pariatur maiores et. Dolor delectus iure accusantium sed.</text>
      #       </plannedStudy>
      #     </protocolDef>
      #   </rpe:RetrieveProtocolDefResponse>
      # </env:Body>

      xml = Gyoku.xml(
        'protocolDef' => {
          'query' => {
            '@root' => '',
            '@extension' => '',
          },
          'plannedStudy' => {
            '@classCode' => 'CLNTRL',
            '@moodCode' => 'DEF',
            'id' => {
              '@root' => '',
              '@extension' => '',
            },
            'title' => study.title,
            'text' => study.brief_description,
          },
        })
      expected = Nokogiri::XML(xml)

      node = epic_received[0].xpath(
          '//env:Body/rpe:RetrieveProtocolDefResponse/protocolDef',
          'env' => 'http://www.w3.org/2003/05/soap-envelope',
          'rpe' => 'urn:ihe:qrph:rpe:2009')

      node.should be_equivalent_to(expected)
    end
  end

end
