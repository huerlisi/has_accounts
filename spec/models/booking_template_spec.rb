require 'spec_helper'

describe BookingTemplate do
  context 'Factory methods' do
    context '.build_booking' do
      it 'should raise an exception if no matching template can be found' do
        expect {BookingTemplate.build_booking('not found')}.to raise_exception
      end

      it 'should call build_booking on the matching template' do
        template = stub_model(BookingTemplate)
        allow(BookingTemplate).to receive(:find_by_code).with('code').and_return(template)
        expect(template).to receive(:build_booking).with({:test => 55})
        BookingTemplate.build_booking 'code', {:test => 55}

      end
    end
  end
end
