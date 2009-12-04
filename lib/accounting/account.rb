module Accounting
  class Account < ActiveRecord::Base
    belongs_to :holder, :polymorphic => true
    
    has_many :credit_bookings, :class_name => "Booking", :foreign_key => "credit_account_id"
    has_many :debit_bookings, :class_name => "Booking", :foreign_key => "debit_account_id"
    
    has_many :bookings, :finder_sql => 'SELECT * FROM bookings WHERE credit_account_id = #{id} OR debit_account_id = #{id} ORDER BY value_date'

    # Standard methods
    def to_s(format = :default)
      case format
      when :short
        "#{code}: CHF #{sprintf('%0.2f', saldo.currency_round)}"
      else
        "#{title} (#{code}): CHF #{sprintf('%0.2f', saldo.currency_round)}"
      end
    end

    def saldo
      credit_amount = credit_bookings.sum(:amount)
      debit_amount = debit_bookings.sum(:amount)

      credit_amount ||= 0
      debit_amount ||= 0

      return credit_amount - debit_amount
    end
  end

  module ClassMethods
    def has_accounts(options = {})
      class_eval <<-end_eval
        has_many :accounts, :class_name => 'Accounting::Account', :as => 'holder'
        has_one :account, :class_name => 'Accounting::Account', :as => 'holder'
      end_eval
    end
  end
end
