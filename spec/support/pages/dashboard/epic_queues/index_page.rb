require 'rails_helper'

module Dashboard
  module EpicQueues
    class IndexPage < SitePrism::Page
      set_url '/dashboard/epic_queues'

      # Protocol column of table
      element :protocol_header, 'th', text: 'Queued Protocol'

      # PI(s) column of table
      element :pis_header, 'th', text: 'PI(s)'

      # Last Queue Date column of table
      element :last_queue_date_header, 'th', text: 'Last Queue Date'

      # Last Queue Status column of table
      element :last_queue_status_header, 'th', text: 'Last Queue Status'
      
      sections :epic_queues, 'tbody tr' do
      end
    end
  end
end