class SearchController < ApplicationController
  def index
    results = Service.where("(name LIKE '%#{params[:term]}%' OR abbreviation LIKE '%#{params[:term]}%') AND is_available != false")
                     .map{|s| {:parents => [s.organization.abbreviation, s.organization.parents.flatten.map(&:abbreviation).reverse].reverse.join(' | '), :label => s.name, :value => s.id, :description => s.description, :sr_id => session[:service_request_id]}}
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end
end
