module HasAccounts
  module Model
    extend ActiveSupport::Concern
    
    included do
      class_attribute :direct_account

      has_many :bookings, :as => :reference, :dependent => :destroy do
        # TODO: duplicated in Booking (without parameter)
        def direct_balance(value_date = nil, direct_account = nil)
          return BigDecimal.new('0') unless proxy_owner.direct_account
          
          direct_account ||= proxy_owner.direct_account
          balance = BigDecimal.new('0')

          # Scope by value_date
          if value_date.is_a? Range or value_date.is_a? Array
            direct_bookings = where("date(value_date) BETWEEN :from AND :to", :from => value_date.first, :to => value_date.last)
          elsif value_date
            direct_bookings = where("date(value_date) <= ?", value_date) if value_date
          else
            direct_bookings = scoped
          end

          # Accumulate
          for booking in direct_bookings.all
            balance += booking.accounted_amount(direct_account)
          end

          balance
        end
      end
    end

    module ClassMethods
    end
    
    module InstanceMethods
      # Delegate to class
      def direct_account
        self.class.direct_account
      end

      # Build booking
      def build_booking(params = {}, template_code = nil)
        template_code ||= self.class.to_s.underscore + ':invoice'
        booking_template = BookingTemplate.find_by_code(template_code)
        
        # Prepare booking parameters
        booking_params = {:reference => self}
        booking_params.merge!(params)

        # Build and assign booking
        booking = booking_template.build_booking(booking_params)
        bookings << booking
        
        booking
      end

      def balance(value_date = nil, direct_account = nil)
        bookings.direct_balance(value_date, direct_account)
      end
    end
  end
end
