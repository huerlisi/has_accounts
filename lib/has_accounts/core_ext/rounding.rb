module HasAccounts #:nodoc:
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

    module BigDecimal
      module Rounding
        def currency_round
          if self.nil?
            return BigDecimal.new("0")
          else
            return (self * 20).round / 20.0
          end
        end
      end
    end
  end
end

class Float #:nodoc:
  include HasAccounts::CoreExtensions::Rounding
end

class BigDecimal #:nodoc:
  include HasAccounts::CoreExtensions::BigDecimal::Rounding
end

class Fixnum #:nodoc:
  include HasAccounts::CoreExtensions::Rounding
end
