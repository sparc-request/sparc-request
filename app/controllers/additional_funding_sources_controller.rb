class AdditionalFundingSourcesController < ApplicationController
  before_action :set_protocol

  before_action :set_additional_funding_source, only: %i[ edit update destroy ]

  def new
    @additional_funding_source = @protocol.additional_funding_sources.new
    respond_to :js, :html
  end

  def edit
    respond_to :js
    @additional_funding_source.assign_attributes(additional_funding_source_params) if params[:additional_funding_source]
  end

  def create
    respond_to :js
    @additional_funding_source = @protocol.additional_funding_sources.new(additional_funding_source_params)
    unless @additional_funding_source.valid?
      @errors = @additional_funding_source.errors
    end
  end

  def update
    respond_to :js
    @additional_funding_source.assign_attributes(additional_funding_source_params) if params[:additional_funding_source]

    unless @additional_funding_source.valid?
      @errors = @additional_funding_source.errors.full_messages
    end
  end

  def destroy
    @additional_funding_source.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to additional_funding_sources_url, notice: "Additional funding source was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_additional_funding_source
      @additional_funding_source = params[:id].present? ? AdditionalFundingSource.find(params[:id]) : AdditionalFundingSource.new
    end

    def set_protocol
      @protocol = params[:protocol_id].present? ? Protocol.find(params[:protocol_id]) : Study.new
    end

    def additional_funding_source_params
      params.require(:additional_funding_source).permit(:id, :funding_source, :funding_source_other, :sponsor_name, :comments, :federal_grant_code, :federal_grant_serial_number, :federal_grant_title, :phs_sponsor, :non_phs_sponsor, :protocol_id)
    end

end
