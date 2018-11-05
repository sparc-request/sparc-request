module NewsFeed
  class ApiAdapter < NewsFeed::Base
    def initialize(api_string="", content_type='application/json', parameters={limit: NewsFeed::Base::POST_LIMIT})
      @content_type = content_type
      @parameters   = parameters
      @url          = NewsFeed::Base::BASE_URL + api_string + parameter_string
    end

    def add_parameter(key, value)
      @parameters[key] = value if key.present? && value.present?
    end

    def get
      HTTParty.get(@url, headers: { 'Content-Type' => @content_type })
    end

    private

    def parameter_string
      @parameters.any? ? "?" + @parameters.map{ |k, v| "#{k}=#{v}" }.join("&") : ""
    end
  end
end
