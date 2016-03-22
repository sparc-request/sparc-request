class Dashboard::Breadcrumber
  include ActionView::Helpers::TagHelper

  def initialize
    clear
  end

  def clear(crumb=nil)
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
    breads = [@crumbs[:protocol_id] && Protocol.find(@crumbs[:protocol_id]).try(:short_title),
      @crumbs[:sub_service_request_id] && SubServiceRequest.find(@crumbs[:sub_service_request_id]).organization.label,
      @crumbs[:notifications] && 'Notifications',
      @crumbs[:edit_protocol] && 'Edit'
    ]
    urls = [@crumbs[:protocol_id] && dashboard_protocol_url(@crumbs[:protocol_id]),
      @crumbs[:sub_service_request_id] && dashboard_sub_service_request_url(@crumbs[:sub_service_request_id]),
      dashboard_notifications_url,
      @crumbs[:protocol_id] && edit_dashboard_protocol_url(@crumbs[:protocol_id])
      ]

    content_tag(:a, 'Dashboard', href: dashboard_protocols_url) + ((breads.zip(urls)).select { |b, _| !b.nil? }.map { |b, url| ' > '.html_safe + content_tag(:a, b, href: url) }.join.html_safe)
  end

  private

  def dashboard_protocols_url
    '/dashboard/protocols'
  end

  def dashboard_protocol_url(protocol_id)
    "/dashboard/protocols/#{protocol_id}"
  end

  def dashboard_sub_service_request_url(sub_service_request_id)
    "/dashboard/sub_service_requests/#{sub_service_request_id}"
  end

  def dashboard_notifications_url
    '/dashboard/notifications'
  end

  def edit_dashboard_protocol_url(protocol_id)
    "/dashboard/protocols/#{protocol_id}/edit"
  end
end
