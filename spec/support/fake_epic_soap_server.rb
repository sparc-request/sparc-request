require 'webrick'
require 'open-uri'
require 'nori'   # xml parsing
require 'gyoku'  # xml construction

class EpicServlet < WEBrick::HTTPServlet::AbstractServlet
  def initialize(*args)
    super(*args)

    @actions = {
      'urn:ihe:qrph:rpe:2009:RetrieveProtocolDefResponse' => method(:retrieve_protocol_def_response),
    }
  end

  def do_POST(request, response)
    content_type, params = parse_content_type(request)
    action = params['action']

    action = @actions[action]

    if not action then
      response.status = 400

    else
      parser = Nori.new
      body = parser.parse(request.body)

      xml = action.call(body, response)

      response.status = 200
      response['Content-Type'] = 'text/xml'
      response.body = xml
    end
  end

  def soap12_envelope(h)
    xml = Gyoku.xml(
      'soap:Envelope' => {
        '@xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        '@xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope',
        'soap:Header' => h[:header] || { },
        'soap:Body' => h[:body],
        }
      )
  end

  def retrieve_protocol_def_response(body, response)
    xml = soap12_envelope(
      body: {
        'RetrieveProtocolDefResponseResponse' => {
          '@xmlns' => 'urn:ihe:qrph:rpe:2009',
          'ResponseCode' => 'PROTOCOL_RECEIVED',
        }
      })

    return xml
  end

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

if $0 == __FILE__ then
  server = WEBrick::HTTPServer.new(:Port => 1984)
  server.mount "/", EpicServlet
  trap "INT" do server.shutdown end
  server.start
end
