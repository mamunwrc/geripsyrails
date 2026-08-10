Sidekiq.configure_server do |config|
  if ENV['REDIS_URL']
    config.redis = { url: ENV['REDIS_URL']}
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 0
  end
end
