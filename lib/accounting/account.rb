module Accounting
  class Account < ActiveRecord::Base
    belongs_to :holder, :polymorphic => true
    
    has_many :credit_bookings, :class_name => "Booking", :foreign_key => "credit_account_id"
    has_many :debit_bookings, :class_name => "Booking", :foreign_key => "debit_account_id"
    
    has_many :bookings, :finder_sql => 'SELECT * FROM bookings WHERE credit_account_id = #{id} OR debit_account_id = #{id} ORDER BY value_date, id'

    # Standard methods
    def to_s(value_range = Date.today, format = :default)
      case format
      when :short
        "#{code}: CHF #{sprintf('%0.2f', saldo(value_range).currency_round)}"
      else
        "#{title} (#{code}): CHF #{sprintf('%0.2f', saldo(value_range).currency_round)}"
      end
    end

    def self.overview(value_range = Date.today, format = :default)
      Accounting::Account.all.map{|a| a.to_s(value_range, format)}
    end
    
    def turnover(selector = Date.today, inclusive = true)
      if selector.is_a? Range or selector.is_a? Array
        if selector.first.is_a? Accounting::Booking
          equality = "=" if inclusive
          if selector.first.value_date == selector.last.value_date
            condition = ["value_date = :value_date AND id >#{equality} :first_id AND id <#{equality} :last_id", {
              :value_date => selector.first.value_date,
              :first_id => selector.first.id,
              :last_id => selector.last.id
            }]
          else
            condition = ["(value_date > :first_value_date AND value_date < :latest_value_date) OR (value_date = :first_value_date AND id >#{equality} :first_id) OR (value_date = :latest_value_date AND id <#{equality} :last_id)", {
              :first_value_date => selector.first.value_date,
              :latest_value_date => selector.last.value_date,
              :first_id => selector.first.id,
              :last_id => selector.last.id
            }]
          end
        elsif
          # TODO support inclusive param
          condition = {:value_date => selector}
        end
      else
        if selector.is_a? Accounting::Booking
          equality = "=" if inclusive
          condition = ["(value_date < :value_date) OR (value_date = :value_date AND id <#{equality} :id)", {:value_date => selector.value_date, :id => selector.id}]
        else
          equality = "=" if inclusive
          condition = ["value_date <#{equality} ?", selector]
        end
      end

      credit_amount = credit_bookings.sum(:amount, :conditions => condition)
      debit_amount = debit_bookings.sum(:amount, :conditions => condition)
      
      [credit_amount || 0.0, debit_amount || 0.0]
    end
    
    def saldo(selector = Date.today)
      credit_amount, debit_amount = turnover(selector)

      return credit_amount - debit_amount
    end
  end

  module ClassMethods
    def has_accounts(options = {})
      class_eval <<-end_eval
        has_many :accounts, :class_name => 'Accounting::Account', :as => 'holder'
        has_one :account, :class_name => 'Accounting::Account', :as => 'holder'
      end_eval
    end
  end
end
