module Accounting
  class Booking < ActiveRecord::Base
    belongs_to :debit_account, :foreign_key => 'debit_account_id', :class_name => "Account"
    belongs_to :credit_account, :foreign_key => 'credit_account_id', :class_name => "Account"

    belongs_to :reference, :polymorphic => true

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
