require 'rack/streaming_proxy'

API::Application.configure do
  config.streaming_proxy.logger             = Rails.logger                          # stdout by default
  config.streaming_proxy.log_verbosity      = Rails.env.production? ? :low : :high  # :low or :high, :low by default
  config.streaming_proxy.num_retries_on_5xx = 5                                     # 0 by default
  config.streaming_proxy.raise_on_5xx       = true                                  # false by default

  # Will be inserted at the end of the middleware stack by default.
  config.middleware.use Rack::StreamingProxy::Proxy do |request|

    # Inside the request block, return the full URI to redirect the request to,
    # or nil/false if the request should continue on down the middleware stack.
    if request.path.start_with?('/proxy/forum')
      path = request.path.sub(/^\/proxy\/forum/,'')
      query = request.query_string
      base_url = Project.current.forum[:base_url]
      "#{base_url}#{path}?#{query}"
    end
  end
end
