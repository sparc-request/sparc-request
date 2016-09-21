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

require 'savon'
require 'securerandom'
require 'builder'

module Savon
  # The Savon client by default does not allow adding new soap headers
  # except via the global configuration.  This monkey patch allows adding
  # soap headers via local (per-message) configuration.
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

  # We also need to be able to grab the configured endpoint and put it
  # into the wsa:To header.
  class Client
    def endpoint
      return @globals[:endpoint] || @wsdl.endpoint
    end
  end
end


# Use this class to send protocols (studies/projects) along with their
# associated billing calendars to Epic via an InterConnect server.
#
# Configuration is stored in config/epic.yml.
class EpicInterface
  class Error < RuntimeError; end

  attr_accessor :errors

  # Create a new EpicInterface
  def initialize(config)
    logfile = File.join(Rails.root, '/log/', "epic-#{Rails.env}.log")
    logger = ActiveSupport::Logger.new(logfile)

    @config = config
    @errors = {}

    @namespace = @config['namespace'] || 'urn:ihe:qrph:rpe:2009'
    @study_root = @config['study_root'] || 'UNCONFIGURED'

    # TODO: I'm not really convinced that Savon is buying us very much
    # other than some added complexity, but it's working, so no point in
    # pulling it out.
    #
    # We must set namespace_identifier to nil here, in order to prevent
    # Savon from prepending a wsdl: prefix to the
    # RetrieveProtocolDefResponse tag and to force it to set an xmlns
    # attribute (ensuring that all the children of the
    # RetrieveProtocolDefResponse element are in the right namespace).
    @client = Savon.client(
        logger: logger,
        soap_version: 2,
        pretty_print_xml: true,
        convert_request_keys_to: :none,
        namespace_identifier: nil,
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
      'wsa:MessageID' => "uuid:#{SecureRandom.uuid}",
      'wsa:To' => @client.endpoint,
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

    begin
      return @client.call(
          action,
          soap_header: soap_header(action),
          message: message)
    rescue Savon::Error => error
      raise Error.new(error.to_s)
    end
  end

  # Send a full study to the Epic InterConnect server.
  def send_study(study)
    message = full_study_message(study)
    call('RetrieveProtocolDefResponse', message)

    # TODO: handle response from the server
  end

  # Send a study creation to the Epic InterConnect server.
  def send_study_creation(study)
    message = study_creation_message(study)
    call('RetrieveProtocolDefResponse', message)
    

    # TODO: handle response from the server
  end

  # Send a study's billing calendar to the Epic InterConnect server.
  # The study must have already been created (via #send_study) before
  # calling this method.
  def send_billing_calendar(study)
    message = study_calendar_definition_message(study)
    call('RetrieveProtocolDefResponse', message)

    # TODO: handle response from the server
  end

  # Build a full study message (study creation and billing calendar) to
  # send to epic and return it as a string.
  def full_study_message(study)
    xml = Builder::XmlMarkup.new(indent: 2)

    xml.query(root: @study_root, extension: "STUDY#{study.id}")

    xml.protocolDef {
      xml.plannedStudy(xmlns: 'urn:hl7-org:v3', classCode: 'CLNTRL', moodCode: 'DEF') {
        xml.id(root: @study_root, extension: "STUDY#{study.id}")
        xml.title study.epic_title
        xml.text study.brief_description

        emit_project_roles(xml, study)
        emit_nct_number(xml, study)
        emit_irb_number(xml, study)
        emit_category_grouper(xml, study)
        emit_study_type(xml, study)
        emit_ide_number(xml, study)
        emit_cofc(xml, study)
        emit_visits(xml, study)
        emit_procedures_and_encounters(xml, study)
      }
    }

    return xml.target!
  end

  # Build a study creation message to send to epic and return it as a
  # string.
  def study_creation_message(study)
    xml = Builder::XmlMarkup.new(indent: 2)

    xml.query(root: @study_root, extension: "STUDY#{study.id}")

    xml.protocolDef {
      xml.plannedStudy(xmlns: 'urn:hl7-org:v3', classCode: 'CLNTRL', moodCode: 'DEF') {
        xml.id(root: @study_root, extension: "STUDY#{study.id}")
        xml.title study.epic_title
        xml.text study.brief_description

        emit_project_roles(xml, study)
        emit_nct_number(xml, study)
        emit_irb_number(xml, study)
        emit_category_grouper(xml, study)
        emit_study_type(xml, study)
        emit_ide_number(xml, study)
        emit_cofc(xml, study)
   
      }
    }
    return xml.target!
  end

  def emit_project_roles(xml, study)
    study.project_roles.each do |project_role|
      next unless project_role.epic_access
      xml.subjectOf(typeCode: 'SUBJ') {
        xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
          role_code = research_role project_role.role
          xml.code(code: role_code)
          xml.value(
              code: project_role.identity.netid.upcase,
              codeSystem: 'netid')
        }
      }
    end
  end

  def emit_nct_number(xml, study)
    nct_number = study.human_subjects_info.try(:nct_number)

    if study.research_types_info.try(:human_subjects) && !nct_number.blank? then
      xml.subjectOf(typeCode: 'SUBJ') {
        xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
          xml.code(code: 'NCT')
          xml.value(value: nct_number)
        }
      }
    end
  end

  def emit_irb_number(xml, study)
    irb_number = study.human_subjects_info.try(:pro_number)
    irb_number = study.human_subjects_info.try(:hr_number) if irb_number.blank?

    if !irb_number.blank? then
      xml.subjectOf(typeCode: 'SUBJ') {
        xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
          xml.code(code: 'IRB')
          xml.value(value: irb_number)
        }
      }
    end
  end

  def emit_category_grouper(xml, study)
    # See constants.yml for conversions
    # GOV - college, federal, foundation, investigator, internal, other
    # CORP - industry

    if study.funding_source.blank? and study.potential_funding_source.blank?
      error_string = "Protocol #{study.id} does not have a funding source."
      @errors[:no_funding_source] = [] unless @errors[:no_funding_source]
      @errors[:no_funding_source] << error_string unless @errors[:no_funding_source].include?(error_string)
      return
    end

    sources = ['industry']

    if sources.include?(study.funding_source) || sources.include?(study.potential_funding_source)
      grouper = 'CORP'
    else
      grouper = 'GOV'
    end

    xml.subjectOf(typeCode: 'SUBJ') {
      xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
        xml.code(code: 'RGCL1')
        xml.value(value: grouper)
      }
    }
  end

  def emit_cofc(xml, study)
    if study.active?
      cofc = study.study_type_answers.where(study_type_question_id: StudyTypeQuestion.where(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id)).where(order:1).first.id).first.answer == true ? 'YES_COFC' : 'NO_COFC'
    else
      cofc = study.study_type_answers.where(study_type_question_id: StudyTypeQuestion.where(study_type_question_group_id: StudyTypeQuestionGroup.where(active:false).pluck(:id)).where(order:2).first.id).first.answer == true ? 'YES_COFC' : 'NO_COFC'
    end

    xml.subjectOf(typeCode: 'SUBJ') {
      xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
        xml.code(code: 'RGCL3')
        xml.value(value: cofc)
      }
    }
  end

  def emit_study_type(xml, study)

    study_type = Portal::StudyTypeFinder.new(study).study_type

    if study_type 
      xml.subjectOf(typeCode: 'SUBJ') {
        xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
          xml.code(code: 'STUDYTYPE')
          xml.value(value: study_type)
        }
      }
    end
  end
  
  def emit_ide_number(xml, study)
    ide_number = study.investigational_products_info.try(:ide_number)

    if study.investigational_products_info && !ide_number.blank? then
      xml.subjectOf(typeCode: 'SUBJ') {
        xml.studyCharacteristic(classCode: 'OBS', moodCode: 'EVN') {
          xml.code(code: 'RGFT2')
          xml.value(value: ide_number)
        }
      }
    end
  end

  # Build a study calendar definition message to send to epic and return
  # it as a string.
  def study_calendar_definition_message(study)
    xml = Builder::XmlMarkup.new(indent: 2)

    xml.query(root: @study_root, extension: "STUDY#{study.id}")

    xml.protocolDef {
      xml.plannedStudy(xmlns: 'urn:hl7-org:v3', classCode: 'CLNTRL', moodCode: 'DEF') {
        xml.id(root: @study_root, extension: "STUDY#{study.id}")
        xml.title study.epic_title
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

        emit_visits(xml, study)
        emit_procedures_and_encounters(xml, study)
      }
    }

    return xml.target!
  end

  def emit_visits(xml, study)
    seq = 0

    study.arms.each do |arm|

      seq += 1

      xml.component4(typeCode: 'COMP') {
        xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
          xml.id(root: @study_root, extension: "STUDY#{study.id}.ARM#{arm.id}")
          xml.title(arm.name)
          xml.code(code: 'CELL', codeSystem: 'n/a')

          cycle = 1

          xml.component1(typeCode: 'COMP') {
            xml.sequenceNumber(value: seq)

            xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
              xml.id(root: @study_root, extension: "STUDY#{study.id}.ARM#{arm.id}.CYCLE#{cycle}")
              xml.title("Cycle #{cycle}")
              xml.code(code: 'CYCLE', codeSystem: 'n/a')

              xml.effectiveTime {
                # TODO: what to do if start_date or end_date is null?
                first_day = arm.visit_groups.first.day rescue 0
                last_day = arm.visit_groups.last.day rescue 0
                xml.low(value: relative_date(first_day, study.start_date))
                xml.high(value: relative_date(last_day, study.start_date))
              }

              arm.visit_groups.each do |visit_group|
                xml.component1(typeCode: 'COMP') {
                  xml.sequenceNumber(value: visit_group.position)
                  xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
                    xml.id(root: @study_root, extension: "STUDY#{study.id}.ARM#{arm.id}.CYCLE#{cycle}.DAY#{visit_group.position}")
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

  def emit_procedures_and_encounters(xml, study)
    study.arms.each do |arm|

      cycle = 1

      arm.visit_groups.each do |visit_group|

        xml.component4(typeCode: 'COMP') {
          xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
            xml.id(root: @study_root, extension: "STUDY#{study.id}.ARM#{arm.id}.CYCLE#{cycle}.DAY#{visit_group.position}")
            xml.title(visit_group.name)
            xml.code(code: 'VISIT', codeSystem: 'n/a')

            emit_procedures(xml, study, arm, visit_group, cycle)
            emit_encounter(xml, study, arm, visit_group)

          } # timePointEventDefinition
        } # component4
      end
    end
  end

  def emit_procedures(xml, study, arm, visit_group, cycle)
    arm.line_items.each do |line_item|
      # We want to skip line items contained in a service request that is still in first draft
      next if ['first_draft', 'draft'].include?(line_item.sub_service_request.status)
      service = line_item.service
      next unless service.send_to_epic

      if not service.cpt_code.blank? then
        service_code = service.cpt_code
        service_code_system = "SPARCCPT"
      elsif not service.charge_code.blank? then
        service_code = service.charge_code
        service_code_system = "SPARCCPT"
      else
        # Skip this service, since it has neither a CPT code nor a Charge
        # code and add to an error list to warn the user
        error_string = "#{service.name} does not have a CPT or a Charge code."
        @errors[:no_code] = [] unless @errors[:no_code]
        @errors[:no_code] << error_string unless @errors[:no_code].include?(error_string)
        next
      end

      liv = LineItemsVisit.for(arm, line_item)
      visit = Visit.for(liv, visit_group)

      # TODO: we don't know if this is right or not
      billing_modifiers = [
        [ nil,  visit.research_billing_qty ],
        [ 'Q1', visit.insurance_billing_qty ],
      ]

      billing_modifiers.each do |modifier, qty|

        qty.times do
          # TODO: there's nowhere in this message to put the quantity
          xml.component1(typeCode: 'COMP') {
            xml.timePointEventDefinition(classCode: 'CTTEVENT', moodCode: 'DEF') {
              xml.id(root: @study_root, extension: "STUDY#{study.id}.ARM#{arm.id}.CYCLE#{cycle}.DAY#{visit_group.position}.PROC#{line_item.id}")
              xml.code(code: 'PROC', codeSystem: service_code_system)

              xml.component2(typeCode: 'COMP') {
                xml.procedure(classCode: 'PROC', moodCode: 'EVN') {
                  xml.code(code: service_code, codeSystem: service_code_system)
                }
              }

              if modifier then
                xml.subjectOf {
                  xml.timePointEventCharacteristic {
                    xml.code(code: 'BILL_MODIFIER', codeSystem: 'n/a')
                    xml.value(value: modifier)
                  }
                }
              end

            } # timePointEventDefinition
          } # component1
        end
      end

    end
  end

  def emit_encounter(xml, study, arm, visit_group)
    epoch = study.start_date

    xml.component2(typeCode: 'COMP') {
      xml.encounter(classCode: 'ENC', moodCode: 'DEF') {
        # TODO: assuming 1-based (but day might be 0-based; we don't know yet)
        day = visit_group.day || visit_group.position

        xml.effectiveTime {
          xml.low(value: relative_date(day - visit_group.window_before, epoch))
          xml.high(value: relative_date(day + visit_group.window_after, epoch))
        }

        xml.activityTime(value: relative_date(day, epoch))
      }
    }
  end

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
  def relative_date(day, epoch)
    date = epoch + day.days
    return date.strftime("%Y%m%d")
  end

  # Returns the role for Epic based off the SPARC User Role
  def research_role role
    return case role
    when 'primary-pi' then 'PI'
    when 'pi' then 'OP'
    when 'co-investigator' then 'OP'
    when 'faculty-collaborator' then 'RC'
    when 'consultant' then 'RC'
    when 'staff-scientist' then 'OP'
    when 'postdoc' then 'OP'
    when 'grad-research-assistant' then 'SC'
    when 'undergrad-research-assistant' then 'SC'
    when 'research-assistant-coordinator' then 'SC'
    when 'technician' then 'OP'
    when 'mentor' then 'RC'
    when 'general-access-user' then 'RC'
    when 'business-grants-manager' then 'RC'
    when 'research-nurse' then 'N'
    when 'other' then 'RC'
    else 'NA'
    end
  end
end
