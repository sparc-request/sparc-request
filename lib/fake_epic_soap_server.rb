# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require 'webrick'
require 'open-uri'
require 'ostruct'
require 'nokogiri' # xml parsing
require 'builder'  # xml construction

# The EpicServlet class is a SOAP server that, to SPARC, looks just like
# an Epic InterConnect server.  Start it up under WEBrick like this:
#
#   server = WEBrick::HTTPServer.new(:Port => 1984)
#   server.mount "/", EpicServlet
#   server.start
#
# and shut it down with:
#
#   server.shutdown
#
class FakeEpicServlet < WEBrick::HTTPServlet::AbstractServlet
  # If @keep_received is true, then every message received is stored in
  # @received.  A regression test can use this to verify that SPARC sent
  # in what was expected.  The message is stored as a Nokogiri document
  # representing the xml that was sent in.
  attr_accessor :keep_received
  attr_reader :received

  # For testing purposes, the server can send back canned results.  By
  # default every message returns success.  You can force an error to be
  # sent back with:
  #
  #   servlet.result << FakeEpicServlet::Result::Error.new(
  #       value: 'soap:Server',
  #       text: 'There was an error.')
  #
  attr_accessor :results

  module Result
    class Success < OpenStruct; end
    class Error < OpenStruct; end
  end

  # Create a new EpicServlet.  This method is called by WEBrick.
  #
  # Inside this method all the dispatching is initialized.  You can add
  # new SOAP actions by appending to @actions.
  def initialize(server, args)
    super(server, args)

    @actions = {
      'RetrieveProtocolDefResponse' => method(:retrieve_protocol_def_response),
    }

    @keep_received = args[:keep_received] || false
    @received = args[:received] || [ ]
    @results = args[:results] || [ ]
  end

  # Handle a POST request.  All SOAP actions are done through HTTP POST.
  def do_POST(request, response)
    content_type, params = parse_content_type(request)

    # In SOAP 1.1, the action is sent in the SOAPAction header.  In
    # SOAP 1.2, it's sent as a parameter to the Content-Type header.
    # Savon sends SOAPAction (even though it's SOAP 1.2), so we need to
    # accept it.  That's okay, because it appears Epic InterConnect
    # (WCF) also will accept the SOAP 1.1 method.
    namespaced_action_name = request['SOAPAction'] || params['action']
    action_name = namespaced_action_name.gsub('"', '').split(':')[-1]

    action = @actions[action_name]

    if not action then
      # Unknown action; send back a 400
      response.status = 400

    else
      body = Nokogiri::XML(request.body)
      @received << body if @keep_received

      xml, status = action.call(body, response)

      response.status = status
      response['Content-Type'] = 'text/xml'
      response.body = xml
    end
  end

  # Wrap the given header and body in a SOAP 1.2 envelope.
  #
  # Keyword arguments:
  #
  #   header: the soap header
  #   body: the soap body
  #
  # Returns a string containing the xml.
  def soap12_envelope(h)
    xml = Builder::XmlMarkup.new(indent:2)

    xml.tag!(
        'soap:Envelope',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope',
        'xmlns:addressing' => 'http://www.w3.org/2005/08/addressing') {
      xml.tag!('soap:Header') { h[:header].call(xml) if h[:header] }
      xml.tag!('soap:Body') { h[:body].call(xml) if h[:body] }
    }
  end

  # Generate a SOAP error that resembles the one sent back by the Epic
  # InterConnect server.  Returns a string containing the xml.
  def soap12_error(body, error)
    # TODO: if the user provided a ws-a messageid, put it in the
    # header in addressing:RelatesTo

    xml = soap12_envelope(
      header: ->(xml) {
        xml.tag!('addressing:Action', 'soap:mustUnderstand' => '1')
      },
      body: ->(xml) {
        xml.tag!('soap:Fault') {
          xml.tag!('soap:Code') {
            xml.tag!('soap:Value', 'soap:Sender')
            xml.tag!('soap:SubCode') {
              xml.tag!('soap:Value', error.value)
            }
          }
          xml.tag!('soap:Reason') {
            xml.tag!('soap:Text', error.text, 'xml:lang' => 'en-US')
          }
        }
      })

    return xml
  end

  # Handle a RetrieveProtocolDefResponse message.
  def retrieve_protocol_def_response(body, response)
    result = @results.shift || Result::Success.new

    case result
    when Result::Error
      xml = soap12_error(body, result)
      status = 500

    when Result::Success
      xml= soap12_envelope(
        body: ->(xml) {
          xml.RetrieveProtocolDefResponse(xmlns: 'urn:ihe:qrph:rpe:2009') do
            xml.ResponseCode('PROTOCOL_RECEIVED')
          end
        })
      status = 200

    else
      raise "Undefined result type #{result}"
    end

    return xml, status
  end

  # Given an http request, grab the content-type header and parse it.
  # Returns a 2-tuple containing:
  #
  #   [ content_type, hash of extra params ]
  #
  def parse_content_type(request)
    # Here's some real ruby-fu for you.  We can't call the methods in
    # the OpenURI::Meta module directly, so we pass in an empty string
    # which gets extended with the Meta module.  Then the methods in the
    # module are accessible to us by calling them on the string we
    # passed in.
    OpenURI::Meta.init(o='')
    o.meta_add_field('content-type', request.content_type)
    type, *params = o.content_type_parse
    return type, Hash[*params.flatten(1)]
  end
end

class FakeEpicServer < WEBrick::HTTPServer
  def wsdl
    wsdl = <<-END
<?xml version="1.0" encoding="utf-8"?>
<wsdl:definitions
        name="ProtocolExecutor"
        targetNamespace="http://tempuri.org/"
        xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
        xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
        xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
        xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/"
        xmlns:tns="http://tempuri.org/"
        xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"
        xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy"
        xmlns:i0="urn:ihe:qrph:rpe:2009"
        xmlns:wsap="http://schemas.xmlsoap.org/ws/2004/08/addressing/policy"
        xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl"
        xmlns:msc="http://schemas.microsoft.com/ws/2005/12/wsdl/contract"
        xmlns:wsa10="http://www.w3.org/2005/08/addressing"
        xmlns:wsx="http://schemas.xmlsoap.org/ws/2004/09/mex"
        xmlns:wsam="http://www.w3.org/2007/05/addressing/metadata">
    <wsp:Policy wsu:Id="IProtocolExecutor_policy">
      <wsp:ExactlyOne>
        <wsp:All>
          <wsaw:UsingAddressing/>
        </wsp:All>
      </wsp:ExactlyOne>
    </wsp:Policy>
    <wsdl:types/>
    <wsdl:binding name="IProtocolExecutor" type="i0:IProtocolExecutor">
      <wsdl:operation name="RetrieveProtocolDefResponse">
        <soap12:operation soapAction="urn:ihe:qrph:rpe:2009:RetrieveProtocolDefResponse" style="document"/>
        <wsdl:input name="RetrieveProtocolDefResponse">
          <soap12:body use="literal"/>
        </wsdl:input>
        <wsdl:output name="RetrieveProtocolDefResponseResponse">
          <soap12:body use="literal"/>
        </wsdl:output>
      </wsdl:operation>
    </wsdl:binding>
    <wsdl:service name="ProtocolExecutor">
        <wsdl:port name="IProtocolExecutor" binding="tns:IProtocolExecutor">
          <soap12:address location="#{endpoint}"/>
        </wsdl:port>
    </wsdl:service>
</wsdl:definitions>
    END
  end

  def serve_wsdl(request, response)
    response.status = 200
    response['Content-Type'] = 'text/xml'
    response.body = wsdl()
  end

  def initialize(options)
    super(options)

    mount "/", FakeEpicServlet, options[:FakeEpicServlet] || { }
    mount_proc "/wsdl", &method(:serve_wsdl)
  end

  def port
    return self.config[:Port]
  end

  def endpoint
    return "http://localhost:#{port}"
  end
end

if $0 == __FILE__ then
  server = FakeEpicServer.run(:Port => 1984)
  trap "INT" do server.shutdown end
  server.start
end

