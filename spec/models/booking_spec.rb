describe Booking do
  subject { FactoryGirl.build :booking }
  
  its(:title) { should == 'Simple Booking' }
end
