Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
config.webpacker.check_yarn_integrity = true

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  BASE_URL = "http://localhost:3000"
  # Rails.application.config.middleware.use ExceptionNotification::Rack,
  # :email => {
  #   :deliver_with => :deliver,
  #   :email_prefix => "[DEVELOPMENT] ",
  #   :sender_address => %{"protograph notifier" <protograph@pykih.com>},
  #   :exception_recipients => %w{ritvvij.parrikh@pykih.com, ab@pykih.com, aashutosh.bhatt@pykih.com}
  # }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "http://localhost:3000", port: 3000 }
  #pub.pykih.com.smtp

  FROM_EMAIL = "Protograph Internals <nidhi@pro.to>"
  # config.action_mailer.smtp_settings = {
  #   address:              "<%=  ENV['SES_ADDRESS'] %>",
  #   port:                 587,
  #   user_name:            "<%=  ENV['SES_USERNAME'] %>",
  #   password:             "<%=  ENV['SES_PASSWORD'] %>",
  #   authentication:       :login,
  #   enable_starttls_auto: true
  # }

  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  AWS_API_DATACAST_URL="https://d9y49oyask.execute-api.ap-south-1.amazonaws.com/development"
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  SitemapGenerator::Sitemap.search_engines = {
    google: "http://www.google.com/webmasters/tools/ping?sitemap=%s",
    bing: "http://www.bing.com/ping?sitemap=%s"
  }
end
