module Portal::PortalHelper
  def breadcrumbs(protocol, sub_service_request)
    breads = [(protocol || sub_service_request.try(:service_request).try(:protocol)).try(:short_title),
      sub_service_request.try(:ssr_id)]
    urls   = [portal_protocol_path(protocol || sub_service_request.try(:service_request).try(:protocol)),
      sub_service_request && portal_admin_sub_service_request_path(sub_service_request.id)]
    content_tag(:a, 'Portal', href: portal_protocols_path) + (breads.take_while { |b| !b.nil? }.zip(urls).map { |b, url| ' > '.html_safe + content_tag(:a, b, href: url) }.join().html_safe)
  end
end
