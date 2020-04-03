class FixProtocolNextSsrId < ActiveRecord::Migration[5.2]
  def change
    # See https://www.pivotaltracker.com/story/show/171602442

    Protocol.where.not(next_ssr_id: nil).each do |protocol|
      old_next_ssr_id = protocol.next_ssr_id.gsub(/^0(0*)/, '').to_i
      last_ssr_id     = protocol.sub_service_requests.last.ssr_id.gsub(/^0(0*)/, '').to_i

      # If the protocol's next_ssr_id is less than or equal to the last SSR's ssr_id then
      # the protocol's next_ssr_id is invalid due to previous bugs
      if old_next_ssr_id <= last_ssr_id
        protocol.next_ssr_id = last_ssr_id + 1
        protocol.save(validate: false)
      end
    end
  end
end
