class Rack::Attack
  # `Rack::Attack` is configured to use the `Rails.cache` value by default,
  # but you can override that by setting the `Rack::Attack.cache.store` value
  cache.store = ActiveSupport::Cache::MemoryStore.new

  # Allow all local traffic
  safelist('allow from localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Allow an IP address to make 5 requests every 5 seconds
  throttle("requests by ip", limit: 5, period: 5) do |req|
    req.ip
  end

  # Send the following response to the throttled clients
  self.throttled_response = ->(env) do
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      503,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{error: "Throttle limit reached. Retry later"}.to_json]
    ]
  end
end