Raven.configure do |config|
  config.dsn = 'https://27ecdfe531d746089be01c68bbbcdadc:555080a10d814c9b817b80cb6c8b3435@sentry.io/132643'
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w[staging production]
end

ENV['RAVEN_TOKEN'] = 'dce8b38a5b4d4400aa4a5d3f426113ed' if Raven.configuration.capture_allowed?
