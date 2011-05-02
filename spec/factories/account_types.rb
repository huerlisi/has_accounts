FactoryGirl.define do
  factory :account_type do
    title 'Test Account Type'
    name 'test'
  end
  
  factory :current_assets, :parent => :account_type do
    title 'Current Assets'
    name 'current_assets'
  end
  factory :outside_capital, :parent => :account_type do
    title 'Outside Capital'
    name 'outside_capital'
  end
  factory :costs, :parent => :account_type do
    title 'Costs'
    name 'costs'
  end
  factory :earnings, :parent => :account_type do
    title 'Earnings'
    name 'earnings'
  end
end
