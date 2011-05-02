FactoryGirl.define do
  factory :account do
    code  '0000'
    title 'Test Account'
    association :account_type
  end
  
  factory :accounts_payable, :parent => :account do
    code  '2000'
    title 'Accounts Payable'
    association :account_type, :factory => :outside_capital
  end

  factory :cash_account, :parent => :account do
    code  '1000'
    title 'Cash'
    association :account_type, :factory => :current_assets
  end
end
