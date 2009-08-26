module Accounting #:nodoc:
  module CoreExtensions #:nodoc:
    module Rounding
      # Rounds the float according to currency rules.
      # Currently targeted to Swiss Francs (CHF), usable
      # for all currencies having 0.05 as smallest unit.
      #
      #   x = 1.337
      #   x.round    # => 1.35
      def currency_round
        if self.nil?
          return 0.0
        else
          return (self * 20).round / 20.0
        end
      end
    end
  end
end

class Float #:nodoc:
  include Accounting::CoreExtensions::Rounding
end

class BigDecimal #:nodoc:
  include Accounting::CoreExtensions::Rounding
end
