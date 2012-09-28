class SearchController < ApplicationController
  def index
    term = params[:term].strip
    results = Service.where("(name LIKE '%#{term}%' OR abbreviation LIKE '%#{term}%') AND is_available is not false")
                     .reject{|s| s.parents.map(&:is_available).compact.all? == false }
                     .map{|s| {:parents => s.parents.map(&:abbreviation).join(' | '), :label => s.name, :value => s.id, :description => s.description, :sr_id => session[:service_request_id]}}
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end
end
