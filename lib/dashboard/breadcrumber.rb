class Dashboard::Breadcrumber
  include ActionView::Helpers::TagHelper

  def initialize
    clear
  end

  def clear(crumb = nil)
    if crumb
      @crumbs.delete(crumb)
    else
      @crumbs = Hash.new
    end
    self
  end

  def add_crumbs(crumbs)
    crumbs.each do |sym, value|
      add_crumb(sym, value)
    end
    self
  end

  def add_crumb(sym, value)
    @crumbs[sym] = value

    self
  end

  def breadcrumbs
    labels_and_urls = [
        protocol_label_and_url,
        edit_protocol_label_and_url,
        ssr_label_and_url,
        notifications_label_and_url
    ].compact!

    r = content_tag(:li, content_tag(:a, 'Dashboard', href: dashboard_protocols_url))
    labels_and_urls.each_with_index do |breadcrumb_array, index|
      label, url = breadcrumb_array
      if index == labels_and_urls.size - 1
        r += content_tag(:li, label, class: "active")
      else
        r += content_tag(:li, content_tag(:a, label, href: url))
      end
    end

    r.html_safe
  end

  private

  def dashboard_protocols_url
    "/dashboard/protocols"
  end

  def protocol_label_and_url
    protocol_id = @crumbs[:protocol_id]
    protocol_id ? ["(#{protocol_id}) " + Protocol.find(protocol_id).try(:short_title), "/dashboard/protocols/#{protocol_id}"] : nil
  end

  def ssr_label_and_url
    sub_service_request_id = @crumbs[:sub_service_request_id]
    sub_service_request_id ? [SubServiceRequest.find(sub_service_request_id).organization.label, "/dashboard/sub_service_requests/#{sub_service_request_id}"] : nil
  end

  def notifications_label_and_url
    @crumbs[:notifications] ? ["Notifications", "/dashboard/notifications"] : nil
  end

  def edit_protocol_label_and_url
    protocol_id = @crumbs[:edit_protocol]
    protocol_id ? ["Edit", "/dashboard/protocols/#{protocol_id}/edit"] : nil
  end
end
