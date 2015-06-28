require 'spec_helper'

describe Booking do
  subject { FactoryGirl.build :booking }

  its(:title) { should == 'Simple Booking' }

  it { is_expected.to belong_to :debit_account }
  it { is_expected.to belong_to :credit_account }
  it { is_expected.to belong_to :template }

  context 'validations' do
    it { is_expected.to accept_values_for(:title, 'Test', 'Test Account!') }
    it { is_expected.not_to accept_values_for(:title, '', nil) }

    it { is_expected.to accept_values_for(:amount, '0', '1.1', 2, 0.752, -88, '-8.3') }
    it { is_expected.not_to accept_values_for(:amount, '', nil, 'nada') }

    it { is_expected.to accept_values_for(:value_date, '1990-01-02', '20.3.2001', Date.today) }
    it { is_expected.not_to accept_values_for(:value_date, '', nil, '30.2.1990', 'heute') }

    it { is_expected.to accept_values_for(:debit_account, FactoryGirl.build(:cash_account), FactoryGirl.build(:accounts_payable)) }
    it { is_expected.not_to accept_values_for(:debit_account, nil) }

    it { is_expected.to accept_values_for(:credit_account, FactoryGirl.build(:cash_account), FactoryGirl.build(:accounts_payable)) }
    it { is_expected.not_to accept_values_for(:credit_account, nil) }
  end

  describe '.by_date' do
    let!(:booking_before) { FactoryGirl.create(:booking, value_date: '2011-05-01') }
    let!(:booking_today) { FactoryGirl.create(:booking, value_date: '2011-05-02') }
    let!(:booking_after) { FactoryGirl.create(:booking, value_date: '2011-05-03') }

    context 'with no arguments' do
      it 'should find all bookings' do
        @date = Date.parse('2011-05-02')

        expect(Booking.by_date).to contain_exactly(booking_today, booking_before, booking_after)
      end
    end

    context 'with one argument' do
      it 'should find bookings on exact day' do
        expect(Booking.by_date(Date.parse('2011-05-02'))).to contain_exactly(booking_today)
      end

      it 'should handle DateTime argument' do
        expect(Booking.by_date(DateTime.parse('2011-05-02'))).to contain_exactly(booking_today)
      end

      it 'should handle string argument' do
        expect(Booking.by_date('2011-05-02')).to contain_exactly(booking_today)
      end
    end

    context 'with two arguments' do
      it 'should find bookings on start date' do
        from = Date.parse('2011-05-02')
        to = nil
        expect(Booking.by_date(from, to)).to include(booking_today)
      end

      it 'should find bookings on end date' do
        from = nil
        to = Date.parse('2011-05-02')
        expect(Booking.by_date(from, to)).to include(booking_today)
      end

      it 'should find bookings between start and end date' do
        FactoryGirl.create(:booking, value_date: '2011-04-30')
        FactoryGirl.create(:booking, value_date: '2011-05-04')

        from = Date.parse('2011-05-01')
        to = Date.parse('2011-05-03')
        expect(Booking.by_date(from, to)).to contain_exactly(booking_before, booking_today, booking_after)
      end
    end
  end

  describe '.by_amount' do
    let!(:booking_little) { FactoryGirl.create(:booking, amount: 0.1) }
    let!(:booking_medium) { FactoryGirl.create(:booking, amount: 1) }
    let!(:booking_much) { FactoryGirl.create(:booking, amount: 10) }

    context 'with no arguments' do
      it 'should find all bookings' do
        expect(Booking.by_amount).to contain_exactly(booking_little, booking_medium, booking_much)
      end
    end

    context 'with one argument' do
      it 'should find bookings with exact amount' do
        expect(Booking.by_amount(1)).to contain_exactly(booking_medium)
      end

      it 'should handle BigDecimal parameters' do
        expect(Booking.by_amount(BigDecimal.new('1'))).to contain_exactly(booking_medium)
      end
    end

    context 'with two arguments' do
      it 'should find bookings with minimum amount' do
        expect(Booking.by_amount(1, nil)).to include(booking_medium)
      end

      it 'should find bookings with maximum amount' do
        expect(Booking.by_amount(nil, 1)).to include(booking_medium)
      end

      it 'should find bookings between minimum and maximum amount' do
        FactoryGirl.create(:booking, amount: 0.01)
        FactoryGirl.create(:booking, amount: 11)

        expect(Booking.by_amount(0.1, 10)).to contain_exactly(booking_little, booking_medium, booking_much)
      end
    end
  end

  describe '.by_account' do
    let!(:account) { FactoryGirl.create(:account) }
    let!(:cash_account) { FactoryGirl.create(:cash_account) }

    it 'should include bookings with account as debit account' do
      booking = FactoryGirl.create(:booking, debit_account: account, credit_account: cash_account)
      expect(Booking.by_account(account.id)).to include(booking)
    end

    it 'should include bookings with account as credit account' do
      booking = FactoryGirl.create(:booking, credit_account: account, debit_account: cash_account)
      expect(Booking.by_account(account.id)).to include(booking)
    end

    it 'should include bookings with account as credit and debit account' do
      booking = FactoryGirl.create(:booking, credit_account: account, debit_account: cash_account)
      expect(Booking.by_account(account.id)).to include(booking)
    end

    it 'should not include bookings not connected to account' do
      booking = FactoryGirl.create(:booking, credit_account: cash_account, debit_account: cash_account)
      expect(Booking.by_account(account.id)).not_to include(booking)
    end
  end

  describe '.accounts' do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:bank_account) { FactoryGirl.create(:bank_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    it 'should work if no bookings are present' do
      expect(Booking.accounts).to be_empty
    end

    it 'should include debit accounts' do
      FactoryGirl.create(:booking, debit_account: cash_account)
      expect(Booking.accounts).to include(cash_account)
    end

    it 'should include credit accounts' do
      FactoryGirl.create(:booking, credit_account: cash_account)
      expect(Booking.accounts).to include(cash_account)
    end

    it 'should include accounts only once' do
      FactoryGirl.create(:booking, debit_account: debit_account, credit_account: cash_account)
      FactoryGirl.create(:booking, debit_account: cash_account, credit_account: debit_account)
      expect(Booking.accounts.count).to eq(2)
    end
  end

  describe 'balances' do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:bank_account) { FactoryGirl.create(:bank_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    it 'should return empty hash if no bookings are present' do
      expect(Booking.balances).to eq({})
    end

    it 'should use accounts as keys' do
      FactoryGirl.create(:booking, debit_account: cash_account)
      expect(Booking.balances.keys[0]).to be_an Account
    end

    it 'should include credit accounts' do
      FactoryGirl.create(:booking, credit_account: cash_account)
      expect(Booking.accounts).to include(cash_account)
    end

    it 'should include accounts only once' do
      FactoryGirl.create(:booking, debit_account: debit_account, credit_account: cash_account)
      FactoryGirl.create(:booking, debit_account: cash_account, credit_account: debit_account)
      expect(Booking.accounts.count).to eq(2)
    end
  end

  describe '.accounted_by' do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    it 'should accept account id as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.accounted_by(debit_account.id).all }.not_to raise_exception
    end

    it 'should accept Account record as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.accounted_by(debit_account).all }.not_to raise_exception
    end

    it 'should raise exception for not existing Account id as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.accounted_by(999_999).all }.to raise_exception
    end

    it 'should raise exception non Account type records as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.accounted_by(Object.new).all }.to raise_exception
    end

    context 'when accounted by debit_account' do
      it 'should use original amount for payment booking' do
        booking = FactoryGirl.create(:invoice_booking)
        expect(Booking.accounted_by(debit_account.id).count).to eq(1)
        expect(Booking.accounted_by(debit_account.id).first.amount).to eq(booking.amount)
      end

      it 'should use negated amount for payment booking' do
        booking = FactoryGirl.create(:payment_booking)
        expect(Booking.accounted_by(debit_account.id).count).to eq(1)
        expect(Booking.accounted_by(debit_account.id).first.amount).to eq(-booking.amount)
      end

      it 'should use 0 as amount for booking having debit account as both debit and credit' do
        booking = FactoryGirl.create(:booking, debit_account: debit_account, credit_account: debit_account)
        expect(Booking.accounted_by(debit_account.id).count).to eq(1)
        expect(Booking.accounted_by(debit_account.id).first.amount).to eq(0)
      end

      it 'should use 0 as amount for booking having debit account as neither debit and credit' do
        booking = FactoryGirl.create(:booking, credit_account: cash_account, debit_account: cash_account)
        expect(Booking.accounted_by(debit_account.id).count).to eq(1)
        expect(Booking.accounted_by(debit_account.id).first.amount).to eq(0)
      end
    end
  end

  describe '.balance_by' do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    it 'should accept account id as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.balance_by(debit_account.id) }.not_to raise_exception
    end

    it 'should accept Account record as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.balance_by(debit_account) }.not_to raise_exception
    end

    it 'should raise exception for not existing Account id as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.balance_by(999_999) }.to raise_exception
    end

    it 'should raise exception non Account type records as parameter' do
      booking = FactoryGirl.create(:invoice_booking)
      expect { Booking.balance_by(Object.new) }.to raise_exception
    end

    context 'when accounted by debit_account' do
      it 'allows summing over the amount' do
        FactoryGirl.create(:invoice_booking, amount: 10, value_date: '2013-10-10')
        FactoryGirl.create(:payment_booking, amount: 9, value_date: '2013-10-11')
        FactoryGirl.create(:invoice_booking, amount: 5, value_date: '2013-10-12')
        FactoryGirl.create(:booking, amount: 99, credit_account: cash_account, debit_account: cash_account, value_date: '2013-10-12')
        FactoryGirl.create(:payment_booking, amount: 7, value_date: '2013-10-13')
        expect(Booking.balance_by(debit_account.id)).to eq(-1)
      end

      it 'takes conditions into account' do
        FactoryGirl.create(:invoice_booking, amount: 10, value_date: '2013-10-10')
        FactoryGirl.create(:payment_booking, amount: 9, value_date: '2013-10-11')
        FactoryGirl.create(:invoice_booking, amount: 5, value_date: '2013-10-12')
        FactoryGirl.create(:booking, amount: 99, credit_account: cash_account, debit_account: cash_account, value_date: '2013-10-12')
        FactoryGirl.create(:payment_booking, amount: 7, value_date: '2013-10-13')
        expect(Booking.by_date(nil, '2013-10-12').balance_by(debit_account.id)).to eq(6)
      end

      it 'should handle non-integer amount' do
        FactoryGirl.create(:invoice_booking, amount: 10.5, value_date: '2013-10-10')
        FactoryGirl.create(:payment_booking, amount: 9.2, value_date: '2013-10-11')
        expect(Booking.balance_by(debit_account.id)).to eq(1.3)
      end

      it 'should ignore non-related bookings' do
        FactoryGirl.create(:invoice_booking, amount: 10.5, value_date: '2013-10-10')
        FactoryGirl.create(:payment_booking, amount: 9.2, value_date: '2013-10-11')
        FactoryGirl.create(:booking, amount: 100, value_date: '2013-10-11', debit_account: FactoryGirl.create(:accounts_payable), credit_account: FactoryGirl.create(:cash_account))
        expect(Booking.balance_by(debit_account.id)).to eq(1.3)
      end
    end
  end

  describe '.unbalanced_by_grouped_reference' do
    let(:cash_account) { FactoryGirl.create(:cash_account) }
    let(:debit_account) { FactoryGirl.create(:debit_account) }

    it 'works with no bookings' do
      Booking.delete_all
      expect(Booking.unbalanced_by_grouped_reference(cash_account)).to eq({})
    end

    it 'does not include balanced references' do
      FactoryGirl.create(:invoice_booking, amount: 10, value_date: '2013-10-10', reference_id: 1)
      FactoryGirl.create(:payment_booking, amount: 11.5, value_date: '2013-10-11', reference_id: 1)
      FactoryGirl.create(:invoice_booking, amount: 1.5, value_date: '2013-10-12', reference_id: 1)
      expect(Booking.unbalanced_by_grouped_reference(debit_account)).to eq({})
    end

    it 'does include unbalanced references' do
      FactoryGirl.create(:invoice_booking, amount: 1, value_date: '2013-10-10')
      FactoryGirl.create(:invoice_booking, amount: 0.5, value_date: '2013-10-11')
      FactoryGirl.create(:invoice_booking, amount: 10, value_date: '2013-10-10', reference_id: 1)
      FactoryGirl.create(:payment_booking, amount: 11.5, value_date: '2013-10-11', reference_id: 1)
      expect(Booking.unbalanced_by_grouped_reference(debit_account)).to eq({
        [nil, nil] => 1.5,
        [nil, 1] => -1.5
      })
    end

    it 'does respect conditions' do
      FactoryGirl.create(:invoice_booking, amount: 1, value_date: '2013-10-10')
      FactoryGirl.create(:invoice_booking, amount: 0.5, value_date: '2013-10-11')
      FactoryGirl.create(:invoice_booking, amount: 10, value_date: '2013-10-10', reference_id: 1)
      FactoryGirl.create(:payment_booking, amount: 11.5, value_date: '2013-10-11', reference_id: 1)
      expect(Booking.where("value_date < '2013-10-11'").unbalanced_by_grouped_reference(debit_account)).to eq({
        [nil, nil] => 1,
        [nil, 1] => 10
      })
    end
  end
end
