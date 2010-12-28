module HasAccounts
  module ClassMethods
    def has_accounts(options = {})
      class_eval <<-end_eval
        has_many :accounts, :as => 'holder'
        has_one :account, :as => 'holder'
      end_eval
    end
  end
end

ActiveRecord::Base.extend(HasAccounts::ClassMethods)
