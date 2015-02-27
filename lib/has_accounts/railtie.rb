require 'has_accounts'
#
# Rails
require 'rails'

# Date/Time handling
require 'validates_timeliness'

module HasAccounts
  class Railtie < Rails::Engine
    engine_name 'has_accounts'
  end
end
