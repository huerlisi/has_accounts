FactoryGirl.define do
  factory :booking do
    value_date     '2011-03-15'
    title          'Simple Booking'
    amount         37.50
    association    :debit_account, :factory => :accounts_payable
    association    :credit_account, :factory => :cash_account

    factory :invoice_booking do
      title 'Invoice'
      association :debit_account, :factory => :debit_account
      association :credit_account, :factory => :earnings_account
    end

    factory :payment_booking do
      title 'Payment'
      association :debit_account, :factory => :cash_account
      association :credit_account, :factory => :debit_account
    end
  end
end
