require 'rails_helper'
require 'support/pages/dashboard/protocols/protocols_list_row_section.rb'
module Dashboard
  module Protocols
    class ProtocolsListSection < SitePrism::Section
      sections :rows, Dashboard::Protocols::ProtocolsListRowSection, 'tr.protocols_index_row'
    end
  end
end
