class Account < ActiveRecord::Base
  # Scopes
  default_scope :order => 'code'
  
  # Dummy scope to make scoped_by happy
  scope :by_value_period, scoped
  
  # Validation
  validates_presence_of :code, :title
  
  # String
  def to_s(format = :default)
    "%s (%s)" % [title, code]
  end

  # Account Type
  # ============
  belongs_to :account_type
  validates_presence_of :account_type

  def is_asset_account?
    Account.by_type(['current_assets', 'capital_assets', 'costs']).exists?(self)
  end
  
  def is_liability_account?
    !is_asset_account?
  end

  scope :by_type, lambda {|value| includes(:account_type).where('account_types.name' => value)} do
    include AccountScopeExtension
  end

  # Holder
  # ======
  belongs_to :holder, :polymorphic => true
  
  # Bookings
  # ========
  has_many :credit_bookings, :class_name => "Booking", :foreign_key => "credit_account_id"
  has_many :debit_bookings, :class_name => "Booking", :foreign_key => "debit_account_id"
  
  def bookings
    Booking.by_account(id)
  end
  
  # Helpers
  # =======
  def self.overview(value_range = Date.today, format = :default)
    Account.all.map{|a| a.to_s(value_range, format)}
  end
  
  # Calculations
  def turnover(selector = Date.today, inclusive = true)
    equality = "=" if inclusive

    if selector.respond_to?(:first) and selector.respond_to?(:last)
      if selector.first.is_a? Booking
        if selector.first.value_date == selector.last.value_date
          condition = ["date(value_date) = :value_date AND id >#{equality} :first_id AND id <#{equality} :last_id", {
            :value_date => selector.first.value_date,
            :first_id => selector.first.id,
            :last_id => selector.last.id
          }]
        else
          condition = ["(value_date > :first_value_date AND value_date < :latest_value_date) OR (date(value_date) = :first_value_date AND id >#{equality} :first_id) OR (date(value_date) = :latest_value_date AND id <#{equality} :last_id)", {
            :first_value_date => selector.first.value_date,
            :latest_value_date => selector.last.value_date,
            :first_id => selector.first.id,
            :last_id => selector.last.id
          }]
        end
      elsif
        if selector.first == selector.last
          condition = ["date(value_date) = :value_date", {
            :value_date => selector.first
          }]
        else
          condition = ["date(value_date) BETWEEN :first_value_date AND :latest_value_date", {
            :first_value_date => selector.first,
            :latest_value_date => selector.last
          }]
        end
      end
    else
      if selector.is_a? Booking
        # date(value_date) is needed on sqlite!
        condition = ["(value_date < :value_date) OR (date(value_date) = :value_date AND id <#{equality} :id)", {:value_date => selector.value_date, :id => selector.id}]
      else
        condition = ["date(value_date) <#{equality} ?", selector]
      end
    end

    credit_amount = credit_bookings.where(condition).sum(:amount)
    debit_amount = debit_bookings.where(condition).sum(:amount)
    
    [credit_amount || 0.0, debit_amount || 0.0]
  end
  
  def saldo(selector = Date.today, inclusive = true)
    credit_amount, debit_amount = turnover(selector, inclusive)

    amount = credit_amount - debit_amount
    
    return is_asset_account? ? amount : -amount
  end
end
