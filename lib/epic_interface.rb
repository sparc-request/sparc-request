require 'savon'
require 'securerandom'
require 'builder'

# The Savon client by default does not allow adding new soap headers
# except via the global configuration.  This monkey patch allows adding
# soap headers via local (per-message) configuration.
module Savon
  class LocalOptions < Options
    def soap_header(header)
      @options[:soap_header] = header
    end
  end

  class Header
    def header
      @header ||= build_header
    end

    def build_header
      header = {}
      header.update(@globals.include?(:soap_header) ? @globals[:soap_header] : {})
      header.update(@locals.include?(:soap_header) ? @locals[:soap_header] : {})
      return header
    end
  end
end

# Use this class to send protocols (studies/projects) along with their
# associated billing calendars to Epic via an InterConnect server.
#
# Configuration is stored in config/epic.yml.
class EpicInterface

  # Create a new EpicInterface
  def initialize(config = nil)
    @config = config || YAML.load_file(Rails.root.join('config', 'epic.yml'))[Rails.env]

    # TODO: grab these from the WSDL
    @namespace = @config['namespace'] || 'urn:ihe:qrph:rpe:2009'
    @root = @config['study_root']

    @client = Savon.client(
        logger: Rails.logger,
        soap_version: 2,
        pretty_print_xml: true,
        convert_request_keys_to: :none,
        namespace_identifier: 'rpe',
        namespace: @namespace,
        endpoint: @config['endpoint'],
        wsdl: @config['wsdl'],
        headers: {
        },
        soap_header: {
        },
        namespaces: {
          'xmlns:wsa' => 'http://www.w3.org/2005/08/addressing',
        })
  end

  def soap_header(msg_type)
    soap_header = {
      'wsa:Action' => "#{@namespace}:#{msg_type}",
      'wsa:MessageID' => SecureRandom.uuid,
      'wsa:To' => @endpoint,
    }

    return soap_header
  end

  # Send the given SOAP action to the server along with the given
  # message.  Automatically builds a header with the right WS-A
  # elements.
  def call(action, message)
    # Wasabi (Savon's WSDL parser) turns CamelCase actions into
    # snake_case.
    if @config['wsdl'] then
      action = action.snakecase.to_sym
    end

    return @client.call(
        action,
        soap_header: soap_header(action),
        message: message)
  end

  # Send a study to the Epic InterConnect server.
  def send_study(study)
    xml = Builder::XmlMarkup.new

    xml.query(root: @root, extension: study.id)

    xml.protocolDef {
      xml.plannedStudy(xmlns: 'urn:hl7-org:v3', classCode: 'CLNTRL', moodCode: 'DEF') {
        xml.id(root: @root, extension: study.id)
        xml.title study.title
        xml.text study.brief_description

        study.project_roles.each do |project_role|
          xml.subjectOf(typeCode: 'SUBJ') {
            xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
              xml.code(code: project_role.role.upcase)
              xml.value('xsi:type' => 'ST', value: project_role.identity.netid)
            }
          }
        end
      }
    }

    call('RetrieveProtocolDefResponse', xml.target!)

    # TODO: handle response from the server
  end

  # Send a study's billing calendar to the Epic InterConnect server.
  # The study must have already been created (via #send_study) before
  # calling this method.
  def send_billing_calendar(study)
    xml = Builder::XmlMarkup.new

    xml.query(root: @root, extension: study.id)

    xml.protocolDef {
      xml.plannedStudy(xmlns: 'urn:hl7-org:v3', classCode: 'CLNTRL', moodCode: 'DEF') {
        xml.id(root: @root, extension: study.id)
        xml.title study.title
        xml.text study.brief_description

        # component1 - One calendar event definition out of a sequence.
        # Must contain a timePointEventDefinition tag.
        #
        # component2 - an event's clinical activity.
        #
        # component4 - One calendar event definition out of an unordered
        # list.  used to define either the study structure (setup of
        # Calendar, Cycles, and Days/Visits) or setup of specific visit
        # (Procedures within a visit.  Also known as activities).

        study.service_requests.each do |service_request|
          service_request.arms.each_with_index do |arm, arm_idx|

            xml.component4(typeCode: 'COMP') {
              xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                xml.id(root: @root, extension: "STUDY#{study.id}.ARM#{arm.id}")
                xml.title(arm.name)
                xml.code(code: 'CELL', codeSystem: 'n/a')

                xml.component1(typeCode: 'COMP') {
                  xml.sequenceNumber(value: arm_idx + 1) 

                  xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                    xml.id(root: @root, extension: "STUDY#{study.id}.ARM#{arm.id}.CYCLE1")
                    xml.title('Cycle 1')
                    xml.code(code: 'CYCLE', codeSystem: 'n/a')

                    xml.effectiveTime {
                      xml.low(value: service_request.start_date) # TODO Probably start date of service request
                      xml.high(value: service_request.end_date) # TODO Probably end date of service request
                    }

                    xml.component1(typeCode: 'COMP') {
                      xml.sequenceNumber(value: 'TODO') # TODO
                      xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                        xml.id(root: @root, extension: 'TODO') # TODO
                        xml.title('TODO') # TODO
                      }
                    }

                  } # timePointEventDefinition
                } # component1
              } # timePointEventDefinition
            } # component4
          end
        end

        study.service_requests.each do |service_request|
          service_request.arms.each do |arm|
            arm.visit_groups.each do |visit_group|
              # TODO: not sure if I'm iterating over the right things
              # here...
              xml.component4(typeCode: 'COMP') {
                xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                  xml.id(root: @root, extension: "STUDY#{study.id}.ARM#{arm.id}.VISITGROUP#{visit_group.id}") # TODO Probably study_id.arm_id.visit_group_id
                  xml.title(visit_group.name)
                  xml.code(code: 'VISIT', codeSystem: 'n/a')

                  arm.line_items.each do |line_item|
                    xml.component1(typeCode: 'COMP') {
                      xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                        xml.id(root: @root, extension: 'TODO') # TODO
                        xml.code(code: 'PROC', codeSystem: 'n/a')

                        xml.component2(typeCode: 'COMP') {
                          xml.procedure(classCode: 'PROC', moodCode: 'EVN') {
                            xml.code(code: 'TODO', codeSystem: 'n/a') # TODO: CPT code for service
                          }
                        }

                      } # timePointEventDefinition
                    } # component1
                  end

                  visit_group.visits.each do |visit| # TODO: is this right?
                    xml.component2(typeCode: 'COMP') {
                      xml.encounter(classCode: 'ENC', moodCode: 'DEF') {
                        xml.effectiveTime {
                          xml.low(value: 'TODO') # TODO Service Request start day + visit.day - visit.window
                          xml.high(value: 'TODO') # TODO Service Request start day + visit.day + visit.window
                        }
                        xml.activityTime(value: 'TODO') # TODO Service Request start day + visit.day
                      }
                    }
                  end

                } # timePointEventDefinition
              } # component4
            end
          end
        end


      }
    }

    call('RetrieveProtocolDefResponse', xml.target!)

    # TODO: handle response from the server
  end
end

