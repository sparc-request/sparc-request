class Admin::ApplicationController < ApplicationController
  before_action :authorize_site_admin

  def set_highlighted_link
    @highlighted_link ||= 'sparc_admin'
  end
end
