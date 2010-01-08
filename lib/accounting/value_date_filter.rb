module Accounting
  class ValueDateFilter
    def self.filter(controller)
      Booking.scope_by_value_date controller.for_value_date
    end
  end
end
