module Accounting
  class BankAccount < Account
    belongs_to :bank

    # Standard methods
    def to_s(format = :default)
      case format
      when :short
        "#{code}: CHF #{sprintf('%0.2f', saldo.currency_round)}"
      else
        "#{title} (#{code}) #{bank.to_s} #{number}: CHF #{sprintf('%0.2f', saldo.currency_round)}"
      end
    end
  end
end
