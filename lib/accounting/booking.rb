module Accounting
  class Booking < ActiveRecord::Base
    validates_presence_of :debit_account, :credit_account, :amount, :value_date
  
    belongs_to :debit_account, :foreign_key => 'debit_account_id', :class_name => "Account"
    belongs_to :credit_account, :foreign_key => 'credit_account_id', :class_name => "Account"

    belongs_to :reference, :polymorphic => true

    def to_s(format = :default)
      case format
      when :short
        "#{value_date.strftime('%d.%m.%Y')}: CHF #{sprintf('%0.2f', amount.currency_round)} #{debit_account.code} => #{credit_account.code}"
      else
        "vom #{value_date.strftime('%d.%m.%Y')} über CHF #{sprintf('%0.2f', amount.currency_round)} von #{debit_account.title} nach #{credit_account.title}"
      end
    end

    def accounted_amount(account)
      if debit_account == account
        return amount
      elsif credit_account == account
        return -(amount)
      else
        return 0.0
      end
    end
  end
end
