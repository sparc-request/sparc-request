module NewsFeed
  class Base
    BASE_URL    = Setting.get_value('news_feed_url')
    POST_LIMIT  = Setting.get_value('news_feed_post_limit')

    # Abstract Method
    #
    # Retrieves content from the provided URL
    def get
      raise NoMethodError
    end

    # Abstract Method
    #
    # Parses the API response to create a collection
    # of posts to be displayed on the News Feed.
    def posts
      raise NoMethodError
    end
  end
end
