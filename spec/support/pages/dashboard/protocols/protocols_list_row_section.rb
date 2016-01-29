require 'rails_helper'

module Dashboard
  module Protocols
    class ProtocolsListRowSection < SitePrism::Section
      element :id_field, 'td.id'
      element :short_title_field, 'td.title'
      element :primary_pi_field, 'td.pis'
      element :requests_field, 'td.requests'
      element :archive_button_field, 'td.archive'

      def id
        id_field.text
      end

      def short_title
        short_title_field.text
      end

      def primary_pis
        primary_pi_field.text
      end
    end
  end
end
