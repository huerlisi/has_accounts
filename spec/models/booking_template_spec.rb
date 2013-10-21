require 'spec_helper'

describe BookingTemplate do
  context 'Factory methods' do
    context '.build_booking' do
      it 'should raise an exception if no matching template can be found' do
        expect {BookingTemplate.build_booking('not found')}.to raise_exception
      end

      it 'should call build_booking on the matching template' do
        expect {Booking_template}.to receive(:
        FactoryGirl.create(:booking_template)
        expect {BookingTemplate.build_booking(booking_template.code)}
      end
    end
  end
end
