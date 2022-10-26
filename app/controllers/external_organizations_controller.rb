class ExternalOrganizationsController < ApplicationController
  before_action :find_protocol
  before_action :find_external_organization, only: [:edit, :update, :destroy]

  def protocol_id
    @protocol.id
    Rails.logger.info "#"*50 + "#{@protocol.id} #############"
  end

  def new
    respond_to :js
    @external_organization = ExternalOrganization.new
    Rails.logger.info "#"*50 + "#{@external_organization} #############"
  end

  def create
    respond_to :js
    @external_organization = ExternalOrganization.new(external_organization_params)
    Rails.logger.info "#"*50 + "#{@external_organization} #############"

    unless @external_organization.valid?
        @errors = @external_organization.errors
    end
  end

  def edit
    respond_to :js
    if params[:external_organization]
      @external_organization.assign_attributes(external_organization_params)
    else
      @external_organization = ExternalOrganization.new
    end
  end

  def update
    respond_to :js
     @external_organization.assign_attributes(external_organization_params)

    unless @external_organization.valid?
        @errors = @external_organization.errors
    end
    Rails.logger.info "#"*50 + "#{@external_organization} #############"
  end

  def destroy
    respond_to :js
  end

  protected

  def find_protocol
    @protocol = params[:protocol_id].present? ? Protocol.find(params[:protocol_id]) : Study.new
    Rails.logger.info "#"*50 + "#{@protocol} #############"
  end

  def find_external_organization
    @external_organization = params[:id].present? ? ExternalOrganization.find(params[:id]) : ExternalOrganization.new
    Rails.logger.info "#"*50 + "find_external_organization = @external_organization"
  end

  def external_organization_params
    params.require(:external_organization).permit(
      :collaborating_org_name,
      :collaborating_org_type,
      :comments
    )
  end
end
