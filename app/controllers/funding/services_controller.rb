class Funding::ServicesController < ApplicationController
  layout "funding"
  protect_from_forgery

  before_action :authenticate_identity!
  before_action :authorize_funding_admin
  before_action :find_funding_opp,  only: [:show]

  def set_highlighted_link
    @highlighted_link = 'sparc_funding'
  end

  def index
    respond_to do |format|
      format.html
      format.json{
        @services = Service.funding_opportunities
        @user = current_user
      }
    end
  end

  def show
    @service = Service.find(params[:id])
  end

  def documents
    @table = params[:table]
    @service_id = params[:id]
    @funding_documents = Document.joins(sub_service_requests: {line_items: :service}).where(services: {id: @service_id}, doc_type: @table).distinct
  end

  private
  def find_funding_opp
    unless @service = Service.exists?(id: params[:id], organization_id: Setting.get_value("funding_org_ids"))
      flash[:alert] = t(:funding)[:flash_message][:not_found]
      redirect_to funding_root_path
    end
  end

end