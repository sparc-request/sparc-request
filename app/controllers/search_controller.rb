class SearchController < ApplicationController
  def services
    term = params[:term].strip
    results = Service.where("(name LIKE '%#{term}%' OR abbreviation LIKE '%#{term}%') AND is_available is not false")
                     .reject{|s| s.parents.map(&:is_available).compact.all? == false }
                     .map{|s| {:parents => s.parents.map(&:abbreviation).join(' | '), :label => s.name, :value => s.id, :description => s.description, :sr_id => session[:service_request_id]}}
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end

  def identities
    term = params[:term].strip
    results = Identity.search(term).map do |i| 
      {
       :label => i.display_name, :value => i.id, :email => i.email, :institution => i.institution, :phone => i.phone, :era_commons_name => i.era_commons_name,
       :college => i.college, :department => i.department, :credentials => i.credentials, :credentials_other => i.credentials_other
      }
    end
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end
end
