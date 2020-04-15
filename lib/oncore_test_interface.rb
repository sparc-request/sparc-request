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

    @namespace = 'urn:ihe:qrph:rpe:2009'
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
      soap_version: 2,
      pretty_print_xml: true,
      wsdl: 'http://localhost:3000/oncore_endpoint/wsdl'
    )
  end

  def soap_header(msg_type)
    header = Builder::XmlMarkup.new(indent: 2)
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
    action = action.snakecase.to_sym
    #end

    begin
      # soap_header = soap_header(action)
      # Rails.logger.info "\n\n\n\n*******header********\n\n\n\n\n#{soap_header}\n\n\n\n*******header********\n\n\n\n\n"
      # Rails.logger.info "\n\n\n\n*******message********\n\n\n\n\n#{message}\n\n\n\n*******message********\n\n\n\n\n"
      response = @client.call(
          action,
          message: message)
      return response
    rescue Savon::Error => error
      Rails.logger.info error.http.code
      raise Error.new(error.to_s)
    rescue => e
      puts "HIT THE ERROR BLOCK"
      Rails.logger.error [e.message, *e.backtrace].join($/)
    end
  end

  # Send a full study to the OnCore endpoint
  def send_study
    message = { "protocolDef":
                { "plannedStudy": {
                    "id": {
                      "@extension": "4088",
                      "@root": "1.2.5.2.3.4"
                    },
                    "title": "A Phase 2 Trial of Nivolumab Plus Ipilimumab, Ipilimumab Alone, or Cabazitaxel ",
                    "text": "A Phase 2 Trial of Nivolumab Plus Ipilimumab, Ipilimumab Alone, or Cabazitaxel in Men with Metastatic Castration-Resistant Prostate Cancer",
                    "subjectOf": [
                      {
                        "studyCharacteristic": {
                          "code": {
                            "@code": "STAT"
                          },
                          "value": {
                            "@value": "IRB INITIAL APPROVAL"
                          }
                        }
                      },
                      {
                        "studyCharacteristic": {
                          "code": {
                            "@code": "STATDT"
                          },
                          "value": {
                            "@value": "20191015"
                          }
                        }
                      },
                      {
                        "studyCharacteristic": {
                          "code": {
                            "@code": "PROTOCOLNO"
                          },
                          "value": {
                            "@value": "4088"
                          }
                        }
                      },
                      {
                        "studyCharacteristic": {
                          "code": {
                            "@code": "ST"
                          },
                          "value": {
                            "@value": "Tre"
                          }
                        }
                      },
                      {
                        "studyCharacteristic": {
                          "code": {
                            "@code": "DEPT"
                          },
                          "value": {
                            "@value": "HOLLINGS CANCER CENTER"
                          }
                        }
                      },
                      {
                        "studyCharacteristic": {
                          "code": {
                            "@code": "MGMTGRP"
                          },
                          "value": {
                            "@value": "CTO Green"
                          }
                        }
                      }
                    ],
                    "component2": [
                      {
                        "arm": {
                          "id": {
                            "@extension": "1.ArmD1"
                          },
                          "title": "ArmD1: Nivolumab Q3W + Ipilimumab Q3W followed by Q4W Nivolumab maintenance"
                        }
                      },
                      {
                        "arm": {
                          "id": {
                            "@extension": "1.ArmD2"
                          },
                          "title": "ArmD2: Nivolumab Q3W + Ipilimumab Q6W followed by Nivolumab maintenance"
                        }
                      },
                      {
                        "arm": {
                          "id": {
                            "@extension": "1.ArmD3"
                          },
                          "title": "ArmD3: Ipilimumab monotherapy Q3W"
                        }
                      },
                      {
                        "arm": {
                          "id": {
                            "@extension": "1.ArmD4"
                          },
                          "title": "ArmD4: SOC Cabazitaxel+ Prednisone or Prednisolone"
                        }
                      },
                      {
                        "arm": {
                          "id": {
                            "@extension": "2.ReTreat1"
                          },
                          "title": "ReTreat1: Nivolumab Q3W + Ipilimumab Q3W followed by Q4W Nivolumab maintenance"
                        }
                      },
                      {
                        "arm": {
                          "id": {
                            "@extension": "2.ReTreat2"
                          },
                          "title": "ReTreat2: Nivolumab Q3W + Ipilimumab Q6W followed by Nivolumab maintenance"
                        }
                      }
                    ]
                  }
                }
              }

    # message = { "protocolDef":
    #             { "plannedStudy": {
    #                 "id": {
    #                   "@extension": "3854A",
    #                   "@root": "1.2.5.2.3.4"
    #                 },
    #                 "title": "null",
    #                 "subjectOf": [
    #                   {
    #                     "studyCharacteristic": {
    #                       "code": {
    #                         "@code": "STAT"
    #                       },
    #                       "value": {
    #                         "@value": "OPEN TO ACCRUAL"
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "studyCharacteristic": {
    #                       "code": {
    #                         "@code": "STATDT"
    #                       },
    #                       "value": {
    #                         "@value": "20200212"
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "studyCharacteristic": {
    #                       "code": {
    #                         "@code": "PROTOCOLNO"
    #                       },
    #                       "value": {
    #                         "@value": "3854A"
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "studyCharacteristic": {
    #                       "code": {
    #                         "@code": "ST"
    #                       },
    #                       "value": {
    #                         "@value": "Bas"
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "studyCharacteristic": {
    #                       "code": {
    #                         "@code": "DEPT"
    #                       },
    #                       "value": {
    #                         "@value": "DERMATOLOGY"
    #                       }
    #                     }
    #                   }
    #                 ],
    #                 "component4": [
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "3854A.BLD",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Calendar:4 Budget:1 Arm:BLD: Upadacitinib [P.O] + Placebo pre-filled syringe OR Dupilumab [SC] + Placebo tablet",
    #                       "code": {
    #                         "@code": "CELL",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "1"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1434",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, Screening Visit",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9844",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Screening Visit, SV"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000101"
    #                               },
    #                               "high": {
    #                                 "@value": "20000101"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "2"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1435",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, Baseline",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9845",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Baseline, BL"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000102"
    #                               },
    #                               "high": {
    #                                 "@value": "20000102"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "3"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1436",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, Treatment",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9846",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 1"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "2"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9847",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 2"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "3"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9848",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 4"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "4"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9849",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 6"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "5"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9850",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 8"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "6"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9851",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 10"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "7"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9852",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 12"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "8"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9853",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 14"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "9"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9854",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 16"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "10"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9855",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 18"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "11"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9856",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 20"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "12"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9857",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 22"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "13"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9858",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Treatment, 24"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000103"
    #                               },
    #                               "high": {
    #                                 "@value": "20000618"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "4"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1430",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, Follow-Up",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9840",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Follow-Up, FU"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000619"
    #                               },
    #                               "high": {
    #                                 "@value": "20000619"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "5"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1432",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, Unscheduled Follow Up",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9842",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Unscheduled Follow Up, UNSCH"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000620"
    #                               },
    #                               "high": {
    #                                 "@value": "20000620"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "6"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1431",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, Phone Follow Up",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9841",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, Phone Follow Up, Phone"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000621"
    #                               },
    #                               "high": {
    #                                 "@value": "20000621"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "7"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1433",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "BLD, PD",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "BLD.9843",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "BLD, PD, PD"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000622"
    #                               },
    #                               "high": {
    #                                 "@value": "20000622"
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ]
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9844",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Screening Visit, SV",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000101"
    #                             },
    #                             "high": {
    #                               "@value": "20000101"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000101"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9845",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Baseline, BL",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000102"
    #                             },
    #                             "high": {
    #                               "@value": "20000102"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000102"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9846",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 1",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000103"
    #                             },
    #                             "high": {
    #                               "@value": "20000103"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000103"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9847",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 2",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000110"
    #                             },
    #                             "high": {
    #                               "@value": "20000110"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000110"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9848",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 4",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000117"
    #                             },
    #                             "high": {
    #                               "@value": "20000117"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000117"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9849",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 6",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000124"
    #                             },
    #                             "high": {
    #                               "@value": "20000124"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000124"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9850",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 8",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000131"
    #                             },
    #                             "high": {
    #                               "@value": "20000131"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000131"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9851",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 10",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000207"
    #                             },
    #                             "high": {
    #                               "@value": "20000207"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000207"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9852",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 12",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000214"
    #                             },
    #                             "high": {
    #                               "@value": "20000214"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000214"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9853",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 14",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000221"
    #                             },
    #                             "high": {
    #                               "@value": "20000221"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000221"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9854",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 16",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000228"
    #                             },
    #                             "high": {
    #                               "@value": "20000228"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000228"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9855",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 18",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000306"
    #                             },
    #                             "high": {
    #                               "@value": "20000306"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000306"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9856",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 20",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000313"
    #                             },
    #                             "high": {
    #                               "@value": "20000313"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000313"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9857",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 22",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000320"
    #                             },
    #                             "high": {
    #                               "@value": "20000320"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000320"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9858",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Treatment, 24",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000327"
    #                             },
    #                             "high": {
    #                               "@value": "20000327"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000327"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9840",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Follow-Up, FU",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000619"
    #                             },
    #                             "high": {
    #                               "@value": "20000619"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000619"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9842",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Unscheduled Follow Up, UNSCH",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000620"
    #                             },
    #                             "high": {
    #                               "@value": "20000620"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000620"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9841",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, Phone Follow Up, Phone",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000621"
    #                             },
    #                             "high": {
    #                               "@value": "20000621"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000621"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "BLD.9843",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "BLD, PD, PD",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000622"
    #                             },
    #                             "high": {
    #                               "@value": "20000622"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000622"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "3854A.Biomarker",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Calendar:4 Budget:1 Arm:Biomarker: Biomarker Sub-Study",
    #                       "code": {
    #                         "@code": "CELL",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "1"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1434",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, Screening Visit",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9844",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Screening Visit, SV"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000101"
    #                               },
    #                               "high": {
    #                                 "@value": "20000101"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "2"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1435",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, Baseline",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9845",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Baseline, BL"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000102"
    #                               },
    #                               "high": {
    #                                 "@value": "20000102"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "3"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1436",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, Treatment",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9846",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 1"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "2"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9847",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 2"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "3"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9848",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 4"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "4"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9849",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 6"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "5"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9850",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 8"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "6"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9851",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 10"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "7"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9852",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 12"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "8"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9853",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 14"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "9"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9854",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 16"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "10"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9855",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 18"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "11"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9856",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 20"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "12"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9857",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 22"
    #                                 }
    #                               },
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "13"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9858",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Treatment, 24"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000103"
    #                               },
    #                               "high": {
    #                                 "@value": "20000618"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "4"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1430",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, Follow-Up",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9840",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Follow-Up, FU"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000619"
    #                               },
    #                               "high": {
    #                                 "@value": "20000619"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "5"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1432",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, Unscheduled Follow Up",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9842",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Unscheduled Follow Up, UNSCH"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000620"
    #                               },
    #                               "high": {
    #                                 "@value": "20000620"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "6"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1431",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, Phone Follow Up",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9841",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, Phone Follow Up, Phone"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000621"
    #                               },
    #                               "high": {
    #                                 "@value": "20000621"
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "sequenceNumber": {
    #                             "@value": "7"
    #                           },
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@extension": "1433",
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "Biomarker, PD",
    #                             "code": {
    #                               "@code": "CYCLE",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component1": [
    #                               {
    #                                 "sequenceNumber": {
    #                                   "@value": "1"
    #                                 },
    #                                 "timePointEventDefinition": {
    #                                   "id": {
    #                                     "@extension": "Biomarker.9843",
    #                                     "@root": "1.2.3.4.8.2"
    #                                   },
    #                                   "title": "Biomarker, PD, PD"
    #                                 }
    #                               }
    #                             ],
    #                             "effectiveTime": {
    #                               "low": {
    #                                 "@value": "20000622"
    #                               },
    #                               "high": {
    #                                 "@value": "20000622"
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ]
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9844",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Screening Visit, SV",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000101"
    #                             },
    #                             "high": {
    #                               "@value": "20000101"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000101"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9845",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Baseline, BL",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000102"
    #                             },
    #                             "high": {
    #                               "@value": "20000102"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000102"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9846",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 1",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000103"
    #                             },
    #                             "high": {
    #                               "@value": "20000103"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000103"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9847",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 2",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000110"
    #                             },
    #                             "high": {
    #                               "@value": "20000110"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000110"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9848",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 4",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000117"
    #                             },
    #                             "high": {
    #                               "@value": "20000117"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000117"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9849",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 6",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000124"
    #                             },
    #                             "high": {
    #                               "@value": "20000124"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000124"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9850",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 8",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000131"
    #                             },
    #                             "high": {
    #                               "@value": "20000131"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000131"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9851",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 10",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000207"
    #                             },
    #                             "high": {
    #                               "@value": "20000207"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000207"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9852",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 12",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000214"
    #                             },
    #                             "high": {
    #                               "@value": "20000214"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000214"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9853",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 14",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000221"
    #                             },
    #                             "high": {
    #                               "@value": "20000221"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000221"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9854",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 16",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000228"
    #                             },
    #                             "high": {
    #                               "@value": "20000228"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000228"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9855",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 18",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000306"
    #                             },
    #                             "high": {
    #                               "@value": "20000306"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000306"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9856",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 20",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000313"
    #                             },
    #                             "high": {
    #                               "@value": "20000313"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000313"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9857",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 22",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000320"
    #                             },
    #                             "high": {
    #                               "@value": "20000320"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000320"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9858",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Treatment, 24",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB VENIPUNCTURE (LAB VENIPUNCTURE)",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "36415",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000327"
    #                             },
    #                             "high": {
    #                               "@value": "20000327"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000327"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9840",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Follow-Up, FU",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000619"
    #                             },
    #                             "high": {
    #                               "@value": "20000619"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000619"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9842",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Unscheduled Follow Up, UNSCH",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000620"
    #                             },
    #                             "high": {
    #                               "@value": "20000620"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000620"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9841",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, Phone Follow Up, Phone",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000621"
    #                             },
    #                             "high": {
    #                               "@value": "20000621"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000621"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   },
    #                   {
    #                     "timePointEventDefinition": {
    #                       "id": {
    #                         "@extension": "Biomarker.9843",
    #                         "@root": "1.2.3.4.8.2"
    #                       },
    #                       "title": "Biomarker, PD, PD",
    #                       "code": {
    #                         "@code": "VISIT",
    #                         "@codeSystem": "1.2.3.4.8.2"
    #                       },
    #                       "component1": [
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "CHG RADIOLOGIC EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         },
    #                         {
    #                           "timePointEventDefinition": {
    #                             "id": {
    #                               "@root": "1.2.3.4.8.2"
    #                             },
    #                             "title": "HB X-RAY EXAM CHEST 2 VIEWS",
    #                             "code": {
    #                               "@code": "PROC",
    #                               "@codeSystem": "1.2.3.4.8.2"
    #                             },
    #                             "component2": {
    #                               "procedure": {
    #                                 "code": {
    #                                   "@code": "71046",
    #                                   "@codeSystem": "3.4.2.3.5"
    #                                 }
    #                               }
    #                             }
    #                           }
    #                         }
    #                       ],
    #                       "component2": {
    #                         "encounter": {
    #                           "effectiveTime": {
    #                             "low": {
    #                               "@value": "20000622"
    #                             },
    #                             "high": {
    #                               "@value": "20000622"
    #                             }
    #                           },
    #                           "activityTime": {
    #                             "@value": "20000622"
    #                           }
    #                         }
    #                       }
    #                     }
    #                   }
    #                 ],
    #                 "component2": [
    #                   {
    #                     "arm": {
    #                       "id": {
    #                         "@extension": "1.BLD"
    #                       },
    #                       "title": "BLD: Upadacitinib [P.O] + Placebo pre-filled syringe OR Dupilumab [SC] + Placebo tablet"
    #                     }
    #                   },
    #                   {
    #                     "arm": {
    #                       "id": {
    #                         "@extension": "1.Biomarker"
    #                       },
    #                       "title": "Biomarker: Biomarker Sub-Study"
    #                     }
    #                   }
    #                 ]
    #               }
    #             }
    #           }

    # message = { "protocolDef": "thing" }

    call('RetrieveProtocolDefResponse', message)

    # TODO: handle response from the server
  end

  # Build RPE data to emulate OnCore sending SOAP message to SPARC.
  # THIS DATA IS ALL FAKE AND DOESN'T WORK ANYMORE
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
            xml.value(value: "OPEN TO ACCRUAL")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "STATDT")
            xml.value(value: "20200212")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "PROTOCOLNO")
            xml.value(value: "3854A")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "ST")
            xml.value(value: "Bas")
          }
        }
        xml.subjectOf {
          xml.studyCharacteristic {
            xml.code(code: "DEPT")
            xml.value(value: "DERMATOLOGY")
          }
        }

        #component4 variation 1
        xml.component4 {
          xml.timePointEventDefinition {
            xml.id(extension: "3854A.BLD", root: "component4 root")
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
