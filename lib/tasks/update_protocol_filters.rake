namespace :data do
  task update_protocol_filters: :environment do
    protocol_filters = ProtocolFilter.all

    protocol_filters.each do |pf|
      if pf.search_query.blank?
        pf.update_attribute(:search_query, '{"search_drop"=>"", "search_text"=>""}')
      elsif pf.search_query.include? '{'
      else
        query = pf.search_query
        pf.update_attribute(:search_query, "{'search_drop'=>'', 'search_text'=>'#{query}'}")
      end
    end
  end
end
