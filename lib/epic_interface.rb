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

class Protocol < ActiveRecord::Base
  # Build a study creation message to send to epic and return it as a
  # string.
  def epic_study_creation_message
    xml = Builder::XmlMarkup.new

    xml.query(root: @root, extension: study.id)

    xml.protocolDef {
      xml.plannedStudy(xmlns: 'urn:hl7-org:v3', classCode: 'CLNTRL', moodCode: 'DEF') {
        xml.id(root: @root, extension: study.id)
        xml.title study.title
        xml.text study.brief_description

        study.project_roles.each do |project_role|
          xml.subjectOf(typeCode: 'SUBJ') {
            # TODO: only send primary PI as PI
            xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
              xml.code(code: project_role.role.upcase)
              # TODO: 'CD' instead of 'ST' for PI and study coordinator
              xml.value('xsi:type' => 'ST', value: project_role.identity.netid)
            }
          }
        end
      }
    }

    return xml.target!
  end

  # Bulid a study calendar definition message to send to epic and return
  # it as a string.
  def epic_study_calendar_definition_message
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
                      # TODO: what to do if start_date or end_date is
                      # null?
                      xml.low(value: service_request.start_date.strftime("%Y%m%d"))
                      xml.high(value: service_request.end_date.strftime("%Y%m%d"))
                    }

                    arm.visit_groups.each do |visit_group|
                      xml.component1(typeCode: 'COMP') {
                        xml.sequenceNumber(value: visit_group.position)
                        xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                          xml.id(root: @root, extension: "STUDY#{study.id}.ARM#{arm.id}.CYCLE1.DAY#{visit_group.position}")
                          xml.title(visit_group.name)
                        }
                      }
                    end

                  } # timePointEventDefinition
                } # component1
              } # timePointEventDefinition
            } # component4
          end
        end

        study.service_requests.each do |service_request|
          service_request.arms.each do |arm|
            arm.visit_groups.each do |visit_group|

              xml.component4(typeCode: 'COMP') {
                xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                  xml.id(root: @root, extension: "STUDY#{study.id}.ARM#{arm.id}.DAY#{visit_group.position}")
                  xml.title(visit_group.name)
                  xml.code(code: 'VISIT', codeSystem: 'n/a')

                  arm.line_items.each do |line_item|
                    xml.component1(typeCode: 'COMP') {
                      xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                        xml.id(root: @root, extension: "STUDY#{study.id}.ARM#{arm.id}.DAY#{visit_group.position}.PROC#{line_item.id}")
                        xml.code(code: 'PROC', codeSystem: 'n/a')

                        xml.component2(typeCode: 'COMP') {
                          xml.procedure(classCode: 'PROC', moodCode: 'EVN') {
                            xml.code(code: line_item.service.cpt_code, codeSystem: 'n/a')
                          }
                        }

                      } # timePointEventDefinition
                    } # component1
                  end

                  xml.component2(typeCode: 'COMP') {
                    xml.encounter(classCode: 'ENC', moodCode: 'DEF') {
                      # TODO: assuming 1-based (but day might be 0-based; we don't know yet)
                      day = visit_group.day || visit_group.position

                      xml.effectiveTime {
                        xml.low(value: epic_relative_date(day - visit_group.window))
                        xml.high(value: epic_relative_date(day + visit_group.window))
                      }

                      xml.activityTime(value: epic_relative_date(day))
                    }
                  }

                } # timePointEventDefinition
              } # component4
            end
          end
        end
      }
    }

    return xml.target!
  end

  private

  # A "relative date" is represented in YYYYMMDD format and is
  # calculated as relative_date + EPOCH.  For example, day 45 would be
  # represented as 20130214 (45th day starting with 20130101 as the
  # epoch).
  #
  # Think this doesn't make much sense?  It doesn't.  I suspect it has
  # to do with <effectiveTime> mapping in Epic to a Java class that MUST
  # contain a valid date.
  #
  # The day passed in here is assumed to be 1-based.
  def epic_relative_date(day)
    date = @epoch + day - 1
    return date.strftime("%Y%m%d")
  end
end

# Use this class to send protocols (studies/projects) along with their
# associated billing calendars to Epic via an InterConnect server.
#
# Configuration is stored in config/epic.yml.
class EpicInterface

  # Create a new EpicInterface
  def initialize(config)
    @config = config

    # TODO: grab these from the WSDL
    @namespace = @config['namespace'] || 'urn:ihe:qrph:rpe:2009'
    @root = @config['study_root']
    @epoch = Date.parse(@config['epoch'] || '2013-01-01')

    # TODO: I'm not really convinced that Savon is buying us very much
    # other than some added complexity, but it's working, so no point in
    # pulling it out.
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
    message = study.epic_study_creation_message
    call('RetrieveProtocolDefResponse', message)

    # TODO: handle response from the server
  end

  # Send a study's billing calendar to the Epic InterConnect server.
  # The study must have already been created (via #send_study) before
  # calling this method.
  def send_billing_calendar(study)
    message = study.epic_study_calendar_definition_message
    call('RetrieveProtocolDefResponse', message)

    # TODO: handle response from the server
  end
end

