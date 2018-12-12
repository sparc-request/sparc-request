module NewsFeed
  class PageParser < NewsFeed::Base
    def initialize
      @post_selector  = Setting.get_value("news_feed_post_selector")
      @title_selector = Setting.get_value("news_feed_title_selector")
      @link_selector  = Setting.get_value("news_feed_link_selector")
      @date_selector  = Setting.get_value("news_feed_date_selector")
    end

    def get
      Nokogiri::HTML(open(NewsFeed::Base::BASE_URL, open_timeout: 5))
    end

    def posts
      begin
        self.get.css.take(NewsFeed::Base::POST_LIMIT).map do |article|
          {
            title:  article.at_css(@title_selector),
            link:   article.at_css(@link_selector),
            date:   article.at_css(@date_selector)
          }
        end
      rescue Net::OpenTimeout
        []
      end
    end
  end
end
