module Accounting
  class Account < ActiveRecord::Base
    belongs_to :holder, :polymorphic => true
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
