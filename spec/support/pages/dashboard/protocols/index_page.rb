require 'rails_helper'
require 'support/pages/dashboard/protocols/protocols_list_section'

module Dashboard
  module Protocols
    class IndexPage < SitePrism::Page
      set_url '/dashboard/protocols'
      section :protocols_list, Dashboard::Protocols::ProtocolsListSection, '#filterrific_results'
    end
  end
end
