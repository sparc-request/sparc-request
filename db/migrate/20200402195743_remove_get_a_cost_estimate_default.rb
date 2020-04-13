class RemoveGetACostEstimateDefault < ActiveRecord::Migration[5.2]
  def up
    if pv = PermissibleValue.find_by_key('get_a_cost_estimate')
      pv.update_attribute(:default, false)
    end

    if s = Setting.find_by_key('updatable_statuses')
      # This should be an array but for some reason on Travis
      # it's being treated as the raw string value
      if s.value.is_a?(String)
        statuses = s.value.gsub("\"get_a_cost_estimate\",", "")
      else
        statuses = s.value.reject{ |status| status == 'get_a_cost_estimate' }
      end
      s.update_attribute(:value, statuses)
    end

    ServiceRequest.eager_load(:sub_service_requests).where(status: 'get_a_cost_estimate').each do |sr|
      if sr.previously_submitted?
        sr.update_attribute(:status, 'submitted')
        sr.update_attribute(:submitted_at, Time.now)

        sr.sub_service_requests.select{ |ssr| ssr.status == 'get_a_cost_estimate' }.each do |ssr|
          ssr.update_attribute(:status, 'submitted')
          ssr.update_attribute(:submitted_at, Time.now)
        end
      else
        sr.update_attribute(:status, 'draft')
        sr.sub_service_requests.select{ |ssr| ssr.status == 'get_a_cost_estimate' }.each do |ssr|
          ssr.update_attribute(:status, 'draft')
        end
      end
    end
  end

  def down
    if pv = PermissibleValue.find_by_key('get_a_cost_estimate')
      pv.update_attribute(:default, true)
    end

    if s = Setting.find_by_key('updatable_statuses')
      statuses = s.value.append('get_a_cost_estimate')
      s.update_attribute(:value, statuses)
    end
  end
end
