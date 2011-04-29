FactoryGirl.define do
  factory :booking do
    value_date     '2011-03-15'
    title          'Simple Booking'
    amount         37.50
    association    :debit_account, :factory => :accounts_payable
    association    :credit_account, :factory => :cash_account
  end
end
