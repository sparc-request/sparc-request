# Copyright © 2011-2019 MUSC Foundation for Research Development
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

#        -------------------------------------        #
# This is a test file to send SOAP messages to the OnCore endpoint
# controller. This is the best way to test it locally, especially
# without good spec coverage. This is ripped from the epic_interface 
# controller because SPARC is essentially intercepting SOAP messages 
# from OnCore that would otherwise be sent to Epic.
#
# This file has no real functionality in SPARC.
# It should be removed before this feature is merged.
#        -------------------------------------        #

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
class OnCoreTestInterface
  class Error < RuntimeError; end

  attr_accessor :errors

  # Create a new OnCoreTestInterface
  def initialize
    logfile = File.join(Rails.root, '/log/', "OnCore-#{Rails.env}.log")
    logger = ActiveSupport::Logger.new(logfile)

    @errors = {}

    @namespace = 'urn:WashOut'
    @study_root = '1.2.5.2.3.4'

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
        endpoint: 'http://localhost:3000/protocol_soap_endpoints/action',
        wsdl: nil,
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
    #if @config['epic_wsdl'] then
    #  action = action.snakecase.to_sym
    #end

    begin
      # soap_header = soap_header(action)
      # Rails.logger.info "\n\n\n\n*******header********\n\n\n\n\n#{soap_header}\n\n\n\n*******header********\n\n\n\n\n"
      # Rails.logger.info "\n\n\n\n*******message********\n\n\n\n\n#{message}\n\n\n\n*******message********\n\n\n\n\n"
      return @client.call(
          action,
          soap_header: soap_header(action),
          message: message)
    rescue Savon::Error => error
      Rails.logger.info error.http.code
      raise Error.new(error.to_s)
    end
  end

  # Send a full study to the OnCore endpoint
  def send_study
    message = full_study_message

    call('RetrieveProtocolDefResponse', message)

    # TODO: handle response from the server
  end

  # Build RPE data to emulate OnCore sending SOAP message to SPARC.
  def full_study_message
    xml = Builder::XmlMarkup.new(indent: 2)

    xml.protocolDef {
      xml.plannedStudy {
        xml.id(extension: "3854", root: "1.2.5.2.3.4")
        xml.title("Test Protocol message (See RMID 3854)")
        xml.text("The description/short description should be here")

        #subjectOf's
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "STAT")
            xml.value(value: "NEW")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "STATDT")
            xml.value(value: "20191018")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "PROTOCOLNO")
            xml.value(value: "3854")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "PI")
            xml.value(code: "19763", codeSystem: "1.2")
          }
        }

        #component4 variation 1
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 1")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component1 {
              xml.sequenceNumber(value: "1")
              xml.timePointEventDefinition {
                xml.id(extension: "outer1 extension", root: "outer1 root")
                xml.title("outer1 title")
                xml.code(code: "outer1 code", codeSystem: "outer1 codeSystem")

                xml.component1 {
                  xml.sequenceNumber(value: "1")
                  xml.timePointEventDefinition {
                    xml.id(extension: "inner1 extension", root: "inner1 root")
                    xml.title("inner1 title")
                  }
                }

                xml.effectiveTime {
                  xml.low(value: "20200101")
                  xml.high(value: "20201231")
                }
              }
            }
            xml.component1 {
              xml.sequenceNumber(value: "2")
              xml.timePointEventDefinition {
                xml.id(extension: "outer2 extension", root: "outer2 root")
                xml.title("outer2 variation1 title")
                xml.code(code: "outer2 code", codeSystem: "outer2 codeSystem")

                xml.component1 {
                  xml.sequenceNumber(value: "1")
                  xml.timePointEventDefinition {
                    xml.id(extension: "inner1 extension", root: "inner1 root")
                    xml.title("inner1 title")
                  }
                }
                xml.component1 {
                  xml.sequenceNumber(value: "2")
                  xml.timePointEventDefinition {
                    xml.id(extension: "inner2 extension", root: "inner2 root")
                    xml.title("inner2 title")
                  }
                }

                xml.effectiveTime {
                  xml.low(value: "var1 - 20200101")
                  xml.high(value: "var1 - 20201231")
                }   
              }
            }
          }
        }

        #component4 variation 2
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 2")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component1 {
              xml.timePointEventDefinition {
                xml.id(extension: "outer1 extension", root: "outer1 root")
                xml.title("outer1 variation2 title")
                xml.code(code: "outer1 code", codeSystem: "outer1 codeSystem")

                xml.component2 {
                  xml.procedure {
                    xml.code(code: "inner1 component2", codeSystem: "3.4.2.3.5")
                  }
                }
              }
            }
            xml.component1 {
              xml.timePointEventDefinition {
                xml.id(extension: "outer2 extension", root: "outer2 root")
                xml.title("outer2 variation2 title")
                xml.code(code: "outer2 code", codeSystem: "outer2 codeSystem")

                xml.component2 {
                  xml.procedure {
                    xml.code(code: "inner2 component2", codeSystem: "3.4.2.3.5")
                  }
                }
              }
            }
            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var2 - 20200101")
                  xml.high(value: "var2 - 20201231")
                }
              }
            }
          }
        }

        #component4 variation 3
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 3")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var3.1 - 20200101")
                  xml.high(value: "var3.1 - 20201231")
                }
                xml.activityTime(value: "var3.1 activityTime 20200101")
              }
            }
          }
        }
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 3")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var3.2 - 20200101")
                  xml.high(value: "var3.2 - 20201231")
                }
                xml.activityTime(value: "var3.2 activityTime 20200101")
              }
            }
          }
        }
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 3")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var3.3 - 20200101")
                  xml.high(value: "var3.3 - 20201231")
                }
                xml.activityTime(value: "var3.3 activityTime 20200101")
              }
            }
          }
        }

        #component4 variation 1
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Iteration 2 Variation 1")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component1 {
              xml.sequenceNumber(value: "1")
              xml.timePointEventDefinition {
                xml.id(extension: "outer1 extension", root: "outer1 root")
                xml.title("outer1 title")
                xml.code(code: "outer1 code", codeSystem: "outer1 codeSystem")

                xml.component1 {
                  xml.sequenceNumber(value: "1")
                  xml.timePointEventDefinition {
                    xml.id(extension: "inner1 extension", root: "inner1 root")
                    xml.title("inner1 title")
                  }
                }

                xml.effectiveTime {
                  xml.low(value: "20200101")
                  xml.high(value: "20201231")
                }
              }
            }
            xml.component1 {
              xml.sequenceNumber(value: "2")
              xml.timePointEventDefinition {
                xml.id(extension: "outer2 extension", root: "outer2 root")
                xml.title("outer2 variation1 title")
                xml.code(code: "outer2 code", codeSystem: "outer2 codeSystem")

                xml.component1 {
                  xml.sequenceNumber(value: "1")
                  xml.timePointEventDefinition {
                    xml.id(extension: "inner1 extension", root: "inner1 root")
                    xml.title("inner1 title")
                  }
                }
                xml.component1 {
                  xml.sequenceNumber(value: "2")
                  xml.timePointEventDefinition {
                    xml.id(extension: "inner2 extension", root: "inner2 root")
                    xml.title("inner2 title")
                  }
                }

                xml.effectiveTime {
                  xml.low(value: "var1 - 20200101")
                  xml.high(value: "var1 - 20201231")
                }   
              }
            }
          }
        }

        #component4 variation 2
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Iteration 2 Variation 2")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component1 {
              xml.timePointEventDefinition {
                xml.id(extension: "outer1 extension", root: "outer1 root")
                xml.title("outer1 variation2 title")
                xml.code(code: "outer1 code", codeSystem: "outer1 codeSystem")

                xml.component2 {
                  xml.procedure {
                    xml.code(code: "inner1 component2", codeSystem: "3.4.2.3.5")
                  }
                }
              }
            }
            xml.component1 {
              xml.timePointEventDefinition {
                xml.id(extension: "outer2 extension", root: "outer2 root")
                xml.title("outer2 iteration 2 variation2 title")
                xml.code(code: "outer2 code", codeSystem: "outer2 codeSystem")

                xml.component2 {
                  xml.procedure {
                    xml.code(code: "inner2 component2", codeSystem: "3.4.2.3.5")
                  }
                }
              }
            }
            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var2 - 20200101")
                  xml.high(value: "var2 - 20201231")
                }
              }
            }
          }
        }

        #component4 variation 3
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 3")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var3.1 - 20200101")
                  xml.high(value: "var3.1 - 20201231")
                }
                xml.activityTime(value: "var3.1 activityTime 20200101")
              }
            }
          }
        }
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 3")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var3.2 - 20200101")
                  xml.high(value: "var3.2 - 20201231")
                }
                xml.activityTime(value: "var3.2 activityTime 20200101")
              }
            }
          }
        }
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "component4 extension", root: "component4 root")
            xml.title("Variation 3")
            xml.code(code: "component4 code", codeSystem: "component4 codeSystem")

            xml.component2 {
              xml.encounter {
                xml.effectiveTime {
                  xml.low(value: "var3.3 - 20200101")
                  xml.high(value: "var3.3 - 20201231")
                }
                xml.activityTime(value: "var3.3 activityTime 20200101")
              }
            }
          }
        }

        xml.component2 {
          xml.arm {
            xml.id(extension: "Arm 1")
            xml.title("Arm 1 Title")
          }
        }
        xml.component2 {
          xml.arm {
            xml.id(extension: "Arm 2")
            xml.title("Arm 2 Title")
          }
        }
      }
    }

    return xml.target!
  end

  ###############################################################
  ###################### Reference Methods ######################
  ###############################################################

  # This appears how the effectiveDate and activeTime(?) values are set
  #
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

  # This might be useful for parsing roles in the subjectOf's
  #
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
    when 'business-grants-manager' then 'SC'
    when 'research-nurse' then 'N'
    when 'other' then 'RC'
    else 'NA'
    end
  end
end
