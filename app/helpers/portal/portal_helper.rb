module Portal::PortalHelper
  def breadcrumbs(protocol, sub_service_request)
    maybe_protocol = find_protocol(protocol, sub_service_request)

    breads = [maybe_protocol.try(:short_title),
      sub_service_request.try(:ssr_id)]
    urls   = [maybe_protocol && portal_protocol_path(maybe_protocol.id),
      sub_service_request && portal_admin_sub_service_request_path(sub_service_request.id)]

    content_tag(:a, 'Portal', href: portal_protocols_path) + (breads.take_while { |b| !b.nil? }.zip(urls).map { |b, url| ' > '.html_safe + content_tag(:a, b, href: url) }.join().html_safe)
  end

  private

  def find_protocol(protocol, sub_service_request)
    protocol || sub_service_request.try(:service_request).try(:protocol)
  end
end
