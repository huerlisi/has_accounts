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

  describe ".by_value_date" do
    it "should find bookings on exact day" do
      date = '2011-05-02'
      booking = FactoryGirl.create(:booking, :value_date => date)
      Booking.by_value_date(date).should include booking
    end
  end

  describe ".by_account" do
    let!(:account) { FactoryGirl.create(:account) }
    let!(:cash_account) { FactoryGirl.create(:cash_account) }

    it "should include bookings with account as debit account" do
      booking = FactoryGirl.create(:booking, :debit_account => account, :credit_account => cash_account)
      Booking.by_account(account.id).should include(booking)
    end

    it "should include bookings with account as credit account" do
      booking = FactoryGirl.create(:booking, :credit_account => account, :debit_account => cash_account)
      Booking.by_account(account.id).should include(booking)
    end

    it "should include bookings with account as credit and debit account" do
      booking = FactoryGirl.create(:booking, :credit_account => account, :debit_account => cash_account)
      Booking.by_account(account.id).should include(booking)
    end

    it "should not include bookings not connected to account" do
      booking = FactoryGirl.create(:booking, :credit_account => cash_account, :debit_account => cash_account)
      Booking.by_account(account.id).should_not include(booking)
    end
  end

  describe ".accounted_by" do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    context "when accounted by debit_account" do
      it "should use original amount for payment booking" do
        booking = FactoryGirl.create(:invoice_booking)
        Booking.accounted_by(debit_account.id).count.should == 1
        Booking.accounted_by(debit_account.id).first.amount.should == booking.amount
      end

      it "should use negated amount for payment booking" do
        booking = FactoryGirl.create(:payment_booking)
        Booking.accounted_by(debit_account.id).count.should == 1
        Booking.accounted_by(debit_account.id).first.amount.should == -booking.amount
      end

      it "should use 0 as amount for booking having debit account as both debit and credit" do
        booking = FactoryGirl.create(:booking, :debit_account => debit_account, :credit_account => debit_account)
        Booking.accounted_by(debit_account.id).count.should == 1
        Booking.accounted_by(debit_account.id).first.amount.should == 0
      end

      it "should use 0 as amount for booking having debit account as neither debit and credit" do
        booking = FactoryGirl.create(:booking, :credit_account => cash_account, :debit_account => cash_account)
        Booking.accounted_by(debit_account.id).count.should == 1
        Booking.accounted_by(debit_account.id).first.amount.should == 0
      end
    end
  end

  describe ".balance_by" do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    context "when accounted by debit_account" do
      it "allows summing over the amount" do
        FactoryGirl.create(:invoice_booking, :amount => 10, :value_date => '2013-10-10')
        FactoryGirl.create(:payment_booking, :amount => 9, :value_date => '2013-10-11')
        FactoryGirl.create(:invoice_booking, :amount => 5, :value_date => '2013-10-12')
        FactoryGirl.create(:booking, :amount => 99, :credit_account => cash_account, :debit_account => cash_account, :value_date => '2013-10-12')
        FactoryGirl.create(:payment_booking, :amount => 7, :value_date => '2013-10-13')
        Booking.balance_by(debit_account.id).should == -1
      end

      it "takes conditions into account" do
        FactoryGirl.create(:invoice_booking, :amount => 10, :value_date => '2013-10-10')
        FactoryGirl.create(:payment_booking, :amount => 9, :value_date => '2013-10-11')
        FactoryGirl.create(:invoice_booking, :amount => 5, :value_date => '2013-10-12')
        FactoryGirl.create(:booking, :amount => 99, :credit_account => cash_account, :debit_account => cash_account, :value_date => '2013-10-12')
        FactoryGirl.create(:payment_booking, :amount => 7, :value_date => '2013-10-13')
        Booking.by_value_period(nil, '2013-10-12').balance_by(debit_account.id).should == 6
      end

      it "should handle non-integer amount" do
        FactoryGirl.create(:invoice_booking, :amount => 10.5, :value_date => '2013-10-10')
        FactoryGirl.create(:payment_booking, :amount => 9.2, :value_date => '2013-10-11')
        Booking.balance_by(debit_account.id).should == 1.3
      end
    end
  end
end
