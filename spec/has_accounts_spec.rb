require 'spec_helper'

describe HasAccounts do
  it "should be valid" do
    HasAccounts.should be_a(Module)
  end
end

describe Invoice do
  it { should respond_to(:bookings) }
  it { should respond_to(:direct_account) }
  
  context "bookings" do
    subject { Invoice.new.bookings }
    
    its(:direct_balance) { should == BigDecimal.new('0') }
  end
end

describe Booking do
  subject { FactoryGirl.build :booking }
  
  its(:title) { should == 'Simple Booking' }
end
