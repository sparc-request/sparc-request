module Portal::AdminHelper
  def ssr_statuses
    arr = {}
    @service_requests.map do |s|
      ssr_status = pretty_tag(s.status).blank? ? "draft" : pretty_tag(s.status)
      if arr[ssr_status].blank?
        arr[ssr_status] = [s]
      else
        arr[ssr_status] << s
      end
    end
    arr
  end

  def full_ssr_id(ssr)
    protocol = ssr.service_request.protocol

    "#{protocol.id}-#{ssr.ssr_id}"
  end

  def display_document_type(type)
    case type
    when 'protocol'      then 'Protocol'
    when 'consent'       then 'Consent'
    when 'hipaa'         then 'HIPAA'
    when 'dsmp'          then 'DSMP'
    when 'budget'        then 'Budget'
    when 'justification' then 'Justification'
    when 'biosketch'     then 'Biosketch'
    end
  end
end
