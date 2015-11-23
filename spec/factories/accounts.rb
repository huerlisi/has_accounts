FactoryGirl.define do
  sequence :account_code do |n|
    "9%03i" % n
  end
end

FactoryGirl.define do
  factory :account do
    code { FactoryGirl.generate(:account_code) }
    title 'Test Account'
    association :account_type
    initialize_with do
      Account.where(code: code).first || Account.create(code: code)
    end

    factory :accounts_payable, parent: :account do
      code '2000'
      title 'Accounts Payable'
      association :account_type
    end

    factory :cash_account, parent: :account do
      code '1000'
      title 'Cash'
      association :account_type
    end

    factory :debit_account, parent: :account do
      code '1100'
      title 'Account Receivable'
      association :account_type, factory: :current_assets
    end

    factory :earnings_account, parent: :account do
      code '3200'
      title 'Revenue Account'
      association :account_type, factory: :earnings
    end
  end
end
