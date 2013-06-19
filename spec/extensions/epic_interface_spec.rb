require 'epic_interface'
require 'spec_helper'

describe EpicInterface do
  server = nil
  servlet = nil
  port = nil
  thread = nil

  before :all do
    require 'webrick'
    server = WEBrick::HTTPServer.new(
        Port: 0,               # automatically determine port
        Logger: Rails.logger,  # send regular log to rails
        AccessLog: [ ]         # disable access log
        )
    server.mount('/', FakeEpicServlet)
    port = server.config[:Port]
    servlet = FakeEpicServlet.get_instance(server)
    thread = Thread.new { server.start }
    timeout(10) { while server.status != :Running; end }
  end

  after :all do
    server.shutdown
    thread.join
  end

  let!(:epic_interface) { EpicInterface.new('endpoint' => "http://localhost:#{port}/") }
  # let!(:study) { Study.create(FactoryGirl.attributes_for(:protocol)) }
  let!(:study) { FactoryGirl.build(:study) }

  describe 'send_study' do
    it 'should do something' do
      epic_interface.send_study(study)
    end
  end

end
