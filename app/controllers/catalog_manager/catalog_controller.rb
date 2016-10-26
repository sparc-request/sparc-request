# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class CatalogManager::CatalogController < CatalogManager::AppController
  respond_to :js, :haml, :json

  def index
    @institutions = Institution.order('`order`')

    @show_unavailable = [true]

    if /false/.match(params[:show_unavailable])
      @show_unavailable << false
    end

  end

  def update_pricing_maps
    percentage = params[:percentage]
    effective_date = params[:effective_date]
    display_date = params[:display_date]
    entity_id = params[:entity_id]

    organization = Organization.find(entity_id)
    services = organization.all_child_services
    @entity = organization

    services_not_updated = []
    services.each do |service|
      old_effective_dates = service.pricing_maps.map{ |pm| pm.effective_date }
      old_display_dates = service.pricing_maps.map{ |pm| pm.display_date }
      if old_effective_dates.include?(effective_date.to_date) || old_display_dates.include?(display_date.to_date)
        services_not_updated << service.name
      else
        service.increase_decrease_pricing_map(percentage, display_date, effective_date)
      end
    end

    if services_not_updated.empty?
      @rsp = "Successfully updated the pricing maps for all of the services under #{@entity.name}."
    else
      @rsp = "Successfully updated the pricing maps for all of the services under #{@entity.name} except for the following: #{services_not_updated.join(', ')}"
    end

  end

  def update_rate(pricing_map, rate_type, percentage)
    if pricing_map.try(:[], "#{rate_type}_rate") && !pricing_map.try(:[], "#{rate_type}_rate").try(:blank?)
      change_number = pricing_map.try(:[], "#{rate_type}_rate") * (percentage.to_f * 0.01)
      pricing_map["#{rate_type}_rate"] = change_number + pricing_map.try(:[], "#{rate_type}_rate")
    end
  end

  def verify_valid_pricing_setups
    ps_array = Catalog.invalid_pricing_setups_for(@user)
    render :text => ps_array.empty? ? 'true' : ps_array.map(&:name).join(', ') + ' have invalid pricing setups'
  end

  def validate_pricing_map_dates
    selector = params[:str]
    entity_id = params[:entity_id]
    _date = params[:date].match(/(\d?\d)\/(\d?\d)\/(\d{4})/)
    date = Date.parse("#{_date[2]}/#{_date[1]}/#{_date[3]}")

    services = Organization.find(entity_id).all_child_services
    there_is_a_same_date = 'false'
    later_dates_exist = 'false'
    services.each do |service|
      service.pricing_maps.each do |pm|
        if pm.send(selector)
          pricing_map_date = Date.parse(pm.send(selector).to_s)
          if pricing_map_date == date
            there_is_a_same_date = 'true'
          elsif pricing_map_date > date
            later_dates_exist = 'true'
          end
        end
      end
    end

    return_error_string = {:same_dates => there_is_a_same_date, :later_dates => later_dates_exist}
    render :json => return_error_string.to_json
  end

  def update_dates_on_pricing_maps
    entity_id = params[:entity_id]
    old_value = params[:old_value]
    old_value_type = params[:old_value_type]
    new_value = params[:new_value]

    services = Organization.find(entity_id).all_child_services

    services.each do |service|
      service.pricing_maps.each do |pm|
        if Date.parse(old_value.to_s) == Date.parse(pm.try(:[], old_value_type).to_s)
          pm[old_value_type] = new_value
          pm.save
        end
      end
      service.save!
    end

    render :text => ""
  end

  def add_excluded_funding_source
    org_id = params[:org_id]
    funding_source = params[:funding_source]
    @organization = case params[:org_type]
    when 'Provider'
      Provider
    when 'Program'
      Program
    when 'Core'
      Core
    end.find(org_id)

    funding_sources = @organization.subsidy_map.excluded_funding_sources
    if funding_sources.map(&:funding_source).include?(funding_source)
      @rsp = false
    else
      @rsp = true
      @funding_source = funding_sources.create({:funding_source => funding_source})
    end
  end

  def remove_excluded_funding_source
    @excluded_funding_source = ExcludedFundingSource.find(params[:funding_source_id])
    @excluded_funding_source.delete
    render :nothing => true
  end

  def remove_associated_survey
    associated_survey = AssociatedSurvey.find(params[:associated_survey_id])
    entity = associated_survey.surveyable
    associated_survey.delete

    render :partial => 'catalog_manager/shared/associated_surveys', :locals => {:entity => entity}
  end

  def add_associated_survey
    entity = params[:surveyable_type].constantize.find params[:surveyable_id]
    associated_survey = entity.associated_surveys.new :survey_id => params[:survey_id]

    #keep the same survey from being associated multiple times, this is also done via the associated_survey model
    if associated_survey.valid?
      associated_survey.save
    else
      message = "The survey you are trying to add is already associated with this #{entity.class.to_s}"
    end

    entity.reload
    render :partial => 'catalog_manager/shared/associated_surveys', :locals => {:entity => entity, :message => message}
  end

  def remove_submission_email
    entity = Organization.find(params["org_unit"])
    submission_email = SubmissionEmail.find(params["submission_email"])

    submission_email.destroy
    render :partial => 'catalog_manager/shared/submission_emails', :locals => {:entity => entity}
  end
end
