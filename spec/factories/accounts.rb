FactoryGirl.define do
  factory :account do
    code  '0000'
    title 'Test Account'
  end
  
  factory :accounts_payable, :parent => :account do
    code  '2000'
    title 'Accounts Payable'
  end

  factory :cash_account, :parent => :account do
    code  '1000'
    title 'Cash'
  end
end
