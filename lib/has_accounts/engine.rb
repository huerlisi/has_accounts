require 'has_accounts'
require 'rails'
require 'validates_timeliness'

module HasAccounts
  # The Engine
  #
  # Integrates the gem with Rails. It adds the models.
  class Engine < Rails::Engine
    engine_name "has_accounts"

    config.generators do |g|
      g.stylesheets false

      g.test_framework :rspec
      g.fixture_replacement :factory_girl
    end
  end
end
