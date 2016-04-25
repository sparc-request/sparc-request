#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

require 'v1/base.rb'

module API

  class Base < Grape::API
    mount SPARCCWF::V1::APIv1
  end
end
