# See Atlassian Confluence API docs here:
# https://developer.atlassian.com/cloud/confluence/rest-api-examples/
module NewsFeed
  class AtlassianAdapter < NewsFeed::ApiAdapter
    def initialize
      api_string  = "/rest/api/content/search"
      limit       = NewsFeed::Base::POST_LIMIT
      space       = Setting.get_value("news_feed_atlassian_space")
      params      = { limit: limit, expand: 'version', cql: "space=#{space} AND type=blogpost order by created desc" }

      super(api_string, 'application/json', params)
    end

    def posts
      begin
        self.get['results'].map do |post|
          {
            title:  post['title'],
            link:   NewsFeed::Base::BASE_URL + post['_links']['webui'],
            date:   post['version']['friendlyWhen']
          }
        end
      rescue
        []
      end
    end
  end
end
