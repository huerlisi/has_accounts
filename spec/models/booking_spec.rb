require 'spec_helper'

describe Booking do
  subject { FactoryGirl.build :booking }

  its(:title) { should == 'Simple Booking' }

  it { should belong_to :debit_account }
  it { should belong_to :credit_account }
  it { should belong_to :template }

  context "validations" do
    it { should accept_values_for(:title, "Test", "Test Account!") }
    it { should_not accept_values_for(:title, "", nil) }

    it { should accept_values_for(:amount, "0", "1.1", 2, 0.752, -88, "-8.3") }
    it { should_not accept_values_for(:amount, "", nil, "nada") }

    it { should accept_values_for(:value_date, "1990-01-02", "20.3.2001", Date.today) }
    it { should_not accept_values_for(:value_date, "", nil, "30.2.1990", "heute") }

    it { should accept_values_for(:debit_account, FactoryGirl.build(:cash_account), FactoryGirl.build(:accounts_payable) ) }
    it { should_not accept_values_for(:debit_account, nil) }

    it { should accept_values_for(:credit_account, FactoryGirl.build(:cash_account), FactoryGirl.build(:accounts_payable) ) }
    it { should_not accept_values_for(:credit_account, nil) }
  end

  context ".by_value_date" do
    it "should find bookings on exact day" do
      date = '2011-05-02'
      booking = FactoryGirl.create(:booking, :value_date => date)
      Booking.by_value_date(date).should include booking
    end
  end

  context ".by_account" do
    let!(:account) { FactoryGirl.create(:account) }
    let!(:cash_account) { FactoryGirl.create(:cash_account) }

    it "should find bookings with account as debit_account" do
      booking = FactoryGirl.create(:booking, :debit_account => account, :credit_account => cash_account)
      Booking.by_account(account.id).should include(booking)
    end

    it "should find bookings with account as credit_account" do
      booking = FactoryGirl.create(:booking, :credit_account => account, :debit_account => cash_account)
      Booking.by_account(account.id).should include(booking)
    end

    it "should not find bookings not connected to account" do
      booking = FactoryGirl.create(:booking, :credit_account => cash_account, :debit_account => cash_account)
      Booking.by_account(account.id).should_not include(booking)
    end
  end
end
