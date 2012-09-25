class SearchController < ApplicationController
  def index
    results = Service.where("name LIKE '%#{params[:term]}%' OR description LIKE '%#{params[:term]}%' OR abbreviation LIKE '%#{params[:term]}%'")
                     .map{|s| {:parents => [s.organization.abbreviation, s.organization.parents.flatten.map(&:abbreviation).reverse].reverse.join(' | '), :label => s.name, :value => s.id}}
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end
end
