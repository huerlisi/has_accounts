class Invoice < ActiveRecord::Base
  # Bookings
  # ========
  include HasAccounts::Model
end
