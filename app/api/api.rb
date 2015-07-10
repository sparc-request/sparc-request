require 'v1/base.rb'

module API

  class Base < Grape::API
    mount SPARCCWF::V1::APIv1
  end
end
