module Accounting
  class Account < ActiveRecord::Base
    belongs_to :holder, :polymorphic => true
    
    has_many :credit_bookings, :class_name => "Booking", :foreign_key => "credit_account_id"
    has_many :debit_bookings, :class_name => "Booking", :foreign_key => "debit_account_id"
    
    has_many :bookings, :finder_sql => 'SELECT * FROM bookings WHERE credit_account_id = #{id} OR debit_account_id = #{id} ORDER BY value_date'
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
