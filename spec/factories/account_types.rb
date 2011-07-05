FactoryGirl.define do
  factory :account_type do
    title 'Test Account Type'
    name 'test'
  
    factory :current_assets do
      title 'Current Assets'
      name 'current_assets'
    end
    factory :outside_capital do
      title 'Outside Capital'
      name 'outside_capital'
    end
    factory :costs do
      title 'Costs'
      name 'costs'
    end
    factory :earnings do
      title 'Earnings'
      name 'earnings'
    end
  end
end
