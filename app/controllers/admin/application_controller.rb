class Admin::ApplicationController < ApplicationController
  def set_highlighted_link
    @highlighted_link ||= 'sparc_admin'
  end
end
