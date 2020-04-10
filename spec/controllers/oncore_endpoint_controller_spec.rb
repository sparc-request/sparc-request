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

require 'rails_helper'

RSpec.describe OncoreEndpointController do
  render_views
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'app', Rails.application

  let_there_be_lane

  before :each do
    @study    = create(:study_federally_funded, research_master_id: 1234, primary_pi: jug2)
    sr        = create(:service_request, protocol: @study)
    @service1 = create(:service_with_process_ssrs_organization, :with_pricing_map, name: "Service 1", eap_id: "0000")
    @service2 = create(:service_with_process_ssrs_organization, :with_pricing_map, name: "Service 2", cpt_code: "0000")
    day1      = Date.new(2000,1,1)
    day5      = Date.new(2000,1,5)
    day10     = Date.new(2000,1,10)
    @wsdl     = "http://app#{oncore_endpoint_wsdl_path}"
    @client   = Savon.client(wsdl: @wsdl)
    # CRPC message with 2 arms, 3 VISITS (not SPARC Visits), and 2 Procedures
    # VISITS are most similar to Visit Groups and Procedures are most like Line Item Visits
    @crpc_message  = { "protocolDef":
                  { "plannedStudy": {
                      "id": {
                        "@extension": @study.research_master_id,
                        "@root": "1.2.5.2.3.4"
                      },
                      "title": "null",
                      "subjectOf": [
                        {
                          "studyCharacteristic": {
                            "code": {
                              "@code": "STAT"
                            },
                            "value": {
                              "@value": "OPEN TO ACCRUAL"
                            }
                          }
                        },
                        {
                          "studyCharacteristic": {
                            "code": {
                              "@code": "STATDT"
                            },
                            "value": {
                              "@value": "20200212"
                            }
                          }
                        },
                        {
                          "studyCharacteristic": {
                            "code": {
                              "@code": "PROTOCOLNO"
                            },
                            "value": {
                              "@value": @study.research_master_id
                            }
                          }
                        },
                        {
                          "studyCharacteristic": {
                            "code": {
                              "@code": "ST"
                            },
                            "value": {
                              "@value": "Bas"
                            }
                          }
                        },
                        {
                          "studyCharacteristic": {
                            "code": {
                              "@code": "DEPT"
                            },
                            "value": {
                              "@value": "DERMATOLOGY"
                            }
                          }
                        }
                      ],
                      "component4": [
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "#{@study.research_master_id}.BLD",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "Calendar:4 Budget:1 Arm:BLD: Arm BLD",
                            "code": {
                              "@code": "CELL",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "sequenceNumber": {
                                  "@value": "1"
                                },
                                "timePointEventDefinition": {
                                  "id": {
                                    "@extension": "1434",
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "BLD, Screening Visit",
                                  "code": {
                                    "@code": "CYCLE",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component1": [
                                    {
                                      "sequenceNumber": {
                                        "@value": "1"
                                      },
                                      "timePointEventDefinition": {
                                        "id": {
                                          "@extension": "BLD.9844",
                                          "@root": "1.2.3.4.8.2"
                                        },
                                        "title": "BLD, Screening Visit, SV"
                                      }
                                    }
                                  ],
                                  "effectiveTime": {
                                    "low": {
                                      "@value": day1.strftime('%Y%m%d')
                                    },
                                    "high": {
                                      "@value": day1.strftime('%Y%m%d')
                                    }
                                  }
                                }
                              },
                              {
                                "sequenceNumber": {
                                  "@value": "2"
                                },
                                "timePointEventDefinition": {
                                  "id": {
                                    "@extension": "1435",
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "BLD, Baseline",
                                  "code": {
                                    "@code": "CYCLE",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component1": [
                                    {
                                      "sequenceNumber": {
                                        "@value": "1"
                                      },
                                      "timePointEventDefinition": {
                                        "id": {
                                          "@extension": "BLD.9845",
                                          "@root": "1.2.3.4.8.2"
                                        },
                                        "title": "BLD, Baseline, BL"
                                      }
                                    }
                                  ],
                                  "effectiveTime": {
                                    "low": {
                                      "@value": day5.strftime('%Y%m%d')
                                    },
                                    "high": {
                                      "@value": day5.strftime('%Y%m%d')
                                    }
                                  }
                                }
                              },
                              {
                                "sequenceNumber": {
                                  "@value": "3"
                                },
                                "timePointEventDefinition": {
                                  "id": {
                                    "@extension": "1436",
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "BLD, Treatment",
                                  "code": {
                                    "@code": "CYCLE",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component1": [
                                    {
                                      "sequenceNumber": {
                                        "@value": "1"
                                      },
                                      "timePointEventDefinition": {
                                        "id": {
                                          "@extension": "BLD.9846",
                                          "@root": "1.2.3.4.8.2"
                                        },
                                        "title": "BLD, Treatment, 1"
                                      }
                                    }
                                  ],
                                  "effectiveTime": {
                                    "low": {
                                      "@value": (day10 - 3.days).strftime('%Y%m%d')
                                    },
                                    "high": {
                                      "@value": (day10 + 3.days).strftime('%Y%m%d')
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "BLD.9844",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "BLD, Screening Visit, SV",
                            "code": {
                              "@code": "VISIT",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service1.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service1.eap_id,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              },
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service2.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service2.cpt_code,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              }
                            ],
                            "component2": {
                              "encounter": {
                                "effectiveTime": {
                                  "low": {
                                    "@value": day1.strftime('%Y%m%d')
                                  },
                                  "high": {
                                    "@value": day1.strftime('%Y%m%d')
                                  }
                                },
                                "activityTime": {
                                  "@value": day1.strftime('%Y%m%d')
                                }
                              }
                            }
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "BLD.9845",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "BLD, Baseline, BL",
                            "code": {
                              "@code": "VISIT",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service1.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service1.eap_id,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              },
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service2.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service2.cpt_code,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              }
                            ],
                            "component2": {
                              "encounter": {
                                "effectiveTime": {
                                  "low": {
                                    "@value": day5.strftime('%Y%m%d')
                                  },
                                  "high": {
                                    "@value": day5.strftime('%Y%m%d')
                                  }
                                },
                                "activityTime": {
                                  "@value": day5.strftime('%Y%m%d')
                                }
                              }
                            }
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "BLD.9846",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "BLD, Treatment, 1",
                            "code": {
                              "@code": "VISIT",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service1.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service1.eap_id,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              },
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service2.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service2.cpt_code,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              }
                            ],
                            "component2": {
                              "encounter": {
                                "effectiveTime": {
                                  "low": {
                                    "@value": (day10 - 3.days).strftime('%Y%m%d')
                                  },
                                  "high": {
                                    "@value": (day10 + 3.days).strftime('%Y%m%d')
                                  }
                                },
                                "activityTime": {
                                  "@value": day10.strftime('%Y%m%d')
                                }
                              }
                            }
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "#{@study.research_master_id}.Biomarker",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "Calendar:4 Budget:1 Arm:Biomarker: Arm Biomarker",
                            "code": {
                              "@code": "CELL",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "sequenceNumber": {
                                  "@value": "1"
                                },
                                "timePointEventDefinition": {
                                  "id": {
                                    "@extension": "1434",
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "Biomarker, Screening Visit",
                                  "code": {
                                    "@code": "CYCLE",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component1": [
                                    {
                                      "sequenceNumber": {
                                        "@value": "1"
                                      },
                                      "timePointEventDefinition": {
                                        "id": {
                                          "@extension": "Biomarker.9844",
                                          "@root": "1.2.3.4.8.2"
                                        },
                                        "title": "Biomarker, Screening Visit, SV"
                                      }
                                    }
                                  ],
                                  "effectiveTime": {
                                    "low": {
                                      "@value": day1.strftime('%Y%m%d')
                                    },
                                    "high": {
                                      "@value": day1.strftime('%Y%m%d')
                                    }
                                  }
                                }
                              },
                              {
                                "sequenceNumber": {
                                  "@value": "2"
                                },
                                "timePointEventDefinition": {
                                  "id": {
                                    "@extension": "1435",
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "Biomarker, Baseline",
                                  "code": {
                                    "@code": "CYCLE",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component1": [
                                    {
                                      "sequenceNumber": {
                                        "@value": "1"
                                      },
                                      "timePointEventDefinition": {
                                        "id": {
                                          "@extension": "Biomarker.9845",
                                          "@root": "1.2.3.4.8.2"
                                        },
                                        "title": "Biomarker, Baseline, BL"
                                      }
                                    }
                                  ],
                                  "effectiveTime": {
                                    "low": {
                                      "@value": day5.strftime('%Y%m%d')
                                    },
                                    "high": {
                                      "@value": day5.strftime('%Y%m%d')
                                    }
                                  }
                                }
                              },
                              {
                                "sequenceNumber": {
                                  "@value": "3"
                                },
                                "timePointEventDefinition": {
                                  "id": {
                                    "@extension": "1436",
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "Biomarker, Treatment",
                                  "code": {
                                    "@code": "CYCLE",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component1": [
                                    {
                                      "sequenceNumber": {
                                        "@value": "1"
                                      },
                                      "timePointEventDefinition": {
                                        "id": {
                                          "@extension": "Biomarker.9846",
                                          "@root": "1.2.3.4.8.2"
                                        },
                                        "title": "Biomarker, Treatment, 1"
                                      }
                                    }
                                  ],
                                  "effectiveTime": {
                                    "low": {
                                      "@value": (day10 - 3.days).strftime('%Y%m%d')
                                    },
                                    "high": {
                                      "@value": (day10 + 3.days).strftime('%Y%m%d')
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "Biomarker.9844",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "Biomarker, Screening Visit, SV",
                            "code": {
                              "@code": "VISIT",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service1.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service1.eap_id,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              },
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service2.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service2.cpt_code,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              }
                            ],
                            "component2": {
                              "encounter": {
                                "effectiveTime": {
                                  "low": {
                                    "@value": day1.strftime('%Y%m%d')
                                  },
                                  "high": {
                                    "@value": day1.strftime('%Y%m%d')
                                  }
                                },
                                "activityTime": {
                                  "@value": day1.strftime('%Y%m%d')
                                }
                              }
                            }
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "Biomarker.9845",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "Biomarker, Baseline, BL",
                            "code": {
                              "@code": "VISIT",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service1.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service1.eap_id,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              },
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service2.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service2.cpt_code,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              }
                            ],
                            "component2": {
                              "encounter": {
                                "effectiveTime": {
                                  "low": {
                                    "@value": day5.strftime('%Y%m%d')
                                  },
                                  "high": {
                                    "@value": day5.strftime('%Y%m%d')
                                  }
                                },
                                "activityTime": {
                                  "@value": day5.strftime('%Y%m%d')
                                }
                              }
                            }
                          }
                        },
                        {
                          "timePointEventDefinition": {
                            "id": {
                              "@extension": "Biomarker.9846",
                              "@root": "1.2.3.4.8.2"
                            },
                            "title": "Biomarker, Treatment, 1",
                            "code": {
                              "@code": "VISIT",
                              "@codeSystem": "1.2.3.4.8.2"
                            },
                            "component1": [
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service1.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service1.eap_id,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              },
                              {
                                "timePointEventDefinition": {
                                  "id": {
                                    "@root": "1.2.3.4.8.2"
                                  },
                                  "title": "#{@service2.name}",
                                  "code": {
                                    "@code": "PROC",
                                    "@codeSystem": "1.2.3.4.8.2"
                                  },
                                  "component2": {
                                    "procedure": {
                                      "code": {
                                        "@code": @service2.cpt_code,
                                        "@codeSystem": "3.4.2.3.5"
                                      }
                                    }
                                  }
                                }
                              }
                            ],
                            "component2": {
                              "encounter": {
                                "effectiveTime": {
                                  "low": {
                                    "@value": (day10 - 3.days).strftime('%Y%m%d')
                                  },
                                  "high": {
                                    "@value": (day10 + 3.days).strftime('%Y%m%d')
                                  }
                                },
                                "activityTime": {
                                  "@value": day10.strftime('%Y%m%d')
                                }
                              }
                            }
                          }
                        }
                      ],
                      "component2": [
                        {
                          "arm": {
                            "id": {
                              "@extension": "1.BLD"
                            },
                            "title": "BLD: Arm BLD"
                          }
                        },
                        {
                          "arm": {
                            "id": {
                              "@extension": "1.Biomarker"
                            },
                            "title": "Biomarker: Arm Biomarker"
                          }
                        }
                      ]
                    }
                  }
                }
  end
  
  describe '#retrieve_protocol_def CRPC message' do
    it 'Imports the service calendar structure' do
      @client.call(:retrieve_protocol_def_response, message: @crpc_message)
      expect(@study.arms.count).to eq(2)
      expect(@study.line_items.count).to eq(2)
      expect(@study.line_items_visits.count).to eq(4)
      expect(@study.visit_groups.count).to eq(6)
      expect(@study.visits.count).to eq(12)
    end

    it 'Sets the Visit Group day, window before, and window after' do
      @client.call(:retrieve_protocol_def_response, message: @crpc_message)
      visit_group1 = @study.arms.first.visit_groups[0]
      visit_group3 = @study.arms.first.visit_groups[2]
      expect(visit_group1.day).to eq(1)
      expect(visit_group1.window_before).to eq(0)
      expect(visit_group1.window_after).to eq(0)
      expect(visit_group3.day).to eq(10)
      expect(visit_group3.window_before).to eq(3)
      expect(visit_group3.window_after).to eq(3)
    end
  end
end
