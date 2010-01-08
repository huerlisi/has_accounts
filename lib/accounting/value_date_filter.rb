module Accounting
  class ValueDateFilter
    def self.filter(controller)
      Booking.scope_by_value_date controller.value_date_scope
    end
  end
end
