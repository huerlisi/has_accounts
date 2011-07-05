require 'spec_helper'

describe Booking do
  subject { FactoryGirl.build :booking }
  
  its(:title) { should == 'Simple Booking' }
  
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
end
