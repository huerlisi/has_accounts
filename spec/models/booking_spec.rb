describe Booking do
  subject { FactoryGirl.build :booking }
  
  its(:title) { should == 'Simple Booking' }
  
  context ".by_value_date" do
    it "should find bookings on exact day" do
      date = '2011-05-02'
      booking = FactoryGirl.create(:booking, :value_date => date)
      Booking.by_value_date(date).should include booking
    end
  end
end
