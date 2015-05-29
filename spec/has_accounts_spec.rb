require 'spec_helper'

describe HasAccounts do
  it 'should be valid' do
    expect(HasAccounts).to be_a(Module)
  end
end

describe Invoice do
  it { is_expected.to respond_to(:bookings) }
  it { is_expected.to respond_to(:direct_account) }

  context 'bookings' do
    subject { Invoice.new.bookings }

    its(:direct_balance) { should == BigDecimal.new('0') }
  end
end
