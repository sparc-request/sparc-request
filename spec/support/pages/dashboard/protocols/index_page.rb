require 'rails_helper'
module Dashboard
  module Protocols
    class IndexPage < SitePrism::Page
      set_url '/dashboard/protocols'

      sections :protocols, '#filterrific_results tr.protocols_index_row' do
        element :id_field, 'td.id'
        element :short_title_field, 'td.title'
        element :primary_pi_field, 'td.pis'
        element :requests_button, 'td.requests button'
        element :archive_button, 'td.archive button'

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

      section :requests_modal, '#requests-modal' do
        element :title, '.modal-header h4'
        sections :service_requests, '.panel.service-request-info' do
          element :pretty_ssr_id, 'td.pretty-ssr-id'
        end
      end
    end
  end
end
