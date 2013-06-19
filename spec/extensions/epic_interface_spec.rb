require 'epic_interface'
require 'spec_helper'

describe EpicInterface do
  server = nil
  port = nil
  thread = nil

  epic_received = [ ]
  epic_results = [ ]

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

  after :all do
    server.shutdown
    thread.join
  end

  before :each do
    epic_received.clear
    epic_results.clear
  end

  let!(:epic_interface) { EpicInterface.new('endpoint' => "http://localhost:#{port}/") }
  # let!(:study) { Study.create(FactoryGirl.attributes_for(:protocol)) }
  let!(:study) { FactoryGirl.build(:study) }

  describe 'send_study' do
    it 'should do something' do
      # TODO: not sure how to handle namespaces...
      epic_interface.send_study(study)
      # epic_received['env:Header']['wsa:Action'].should eq "urn:ihe:qrph:rpe:2009:RetrieveProtocolDefResponse"
      # epic_received['env:Header']['wsa:MessageID'].should_not eq nil
      # epic_received['env:Header']['wsa:To'].should_not eq nil
      # epic_interface['env:Body']['rpe:RetrieveProtocolDefResponse'].should eq({
      #    "rpe:RetrieveProtocolDefResponse"=> {
      #      'protocolDef'=> {
      #        'query' => {
      #          '@root'=> '',
      #          '@extension' => ''
      #        },
      #       'plannedStudy'=> {
      #         'id'=> {
      #           '@root' => '',
      #           '@extension' => ''
      #         },
      #         '@classCode' => 'CLNTRL',
      #         '@moodCode' => 'DEF',
      #         'title' => study.title,
      #         'text' => study.brief_description,
      #   '@xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
      #   '@xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      #   '@xmlns:rpe' => 'urn:ihe:qrph:rpe:2009',
      #   '@xmlns:env' => 'http://www.w3.org/2003/05/soap-envelope'}}]
      # })

    end
  end

end
