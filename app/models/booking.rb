class Booking < ActiveRecord::Base
  # Access restrictions
  attr_accessible :title, :comments, :amount, :value_date, :code

  # Validation
  validates_presence_of :debit_account, :credit_account, :title, :value_date
  validates :amount, :presence => true, :numericality => true
  validates_time :value_date

  # Template
  belongs_to :template, :polymorphic => true

  # Account
  belongs_to :debit_account, :foreign_key => 'debit_account_id', :class_name => "Account"
  attr_accessible :debit_account, :debit_account_id
  belongs_to :credit_account, :foreign_key => 'credit_account_id', :class_name => "Account"
  attr_accessible :credit_account, :credit_account_id

  def debit_account_code
    debit_account.code
  end
  def debit_account_code=(value)
    debit_account = Account.find_by_code(value)
  end

  def credit_account_code
    credit_account.code
  end
  def credit_account_code=(value)
    credit_account = Account.find_by_code(value)
  end

  def direct_account
    return nil unless reference

    return reference.direct_account if reference.respond_to? :direct_account
  end

  def contra_account(account = nil)
    # Derive from direct_account if available
    account ||= direct_account

    return unless account

    if debit_account == account
      return credit_account
    elsif credit_account == account
      return debit_account
    else
      return nil
    end
  end

  def balance_account
    return credit_account if credit_account.is_balance_account?
    return debit_account if debit_account.is_balance_account?
  end

  def profit_account
    return credit_account if credit_account.is_profit_account?
    return debit_account if debit_account.is_profit_account?
  end

  # Scoping
  default_scope order('value_date, id')

  scope :by_value_date, lambda {|value_date| where("date(value_date) = ?", value_date) }
  scope :by_value_period, lambda {|from, to|
    if from.present?
      where("date(value_date) BETWEEN :from AND :to", :from => from, :to => to)
    else
      where("date(value_date) <= :to", :to => to)
    end
  }

  # Scope for all accounts assigned to account
  #
  # @param account_id [Integer]
  scope :by_account, lambda {|account_id|
    where("debit_account_id = :account_id OR credit_account_id = :account_id", :account_id => account_id)
  } do
    # Returns array of all booking titles.
    def titles
      find(:all, :group => :title).map{|booking| booking.title}
    end

    # Statistics per booking title.
    #
    # The statistics are an array of hashes with keys title, count, sum, average.
    def statistics
      find(:all, :select => "title, count(*) AS count, sum(amount) AS sum, avg(amount) AS avg", :group => :title).map{|stat| stat.attributes}
    end
  end

  # Accounted bookings
  # ==================
  SELECT_ACCOUNTED_AMOUNT=
    'CASE WHEN credit_account_id = debit_account_id THEN 0.0 WHEN credit_account_id = %s THEN -bookings.amount ELSE bookings.amount END'

  # Scope where booking amounts are signed according to debit or credit side
  #
  # @param account_or_id Account id or object
  scope :accounted_by, lambda {|account_or_id|
    if account_or_id.is_a? Account
      account_id = account_or_id.id
    elsif Account.exists?(account_or_id)
      account_id = account_or_id
    else
      raise "accounted_by argument needs to be a record of type Account or an id for an existing Account record."
    end

    select("bookings.*, #{SELECT_ACCOUNTED_AMOUNT % account_id} AS amount")
  }

  # Balance of bookings for the specified account
  #
  # @param account_or_id Account id or object
  def self.balance_by(account_or_id)
    if account_or_id.is_a? Account
      account_id = account_or_id.id
    elsif Account.exists?(account_or_id)
      account_id = account_or_id
    else
      raise "accounted_by argument needs to be a record of type Account or an id for an existing Account record."
    end

    BigDecimal.new(sum(SELECT_ACCOUNTED_AMOUNT % account_id), 2)
  end

  scope :by_text, lambda {|value|
    text   = '%' + value + '%'

    amount = value.delete("'").to_f
    if amount == 0.0
      amount = nil unless value.match(/^[0.]*$/)
    end

    date   = nil
    begin
      date = Date.parse(value)
    rescue ArgumentError
    end

    where("title LIKE :text OR comments LIKE :text OR amount = :amount OR value_date = :value_date", :text => text, :amount => amount, :value_date => date)
  }

  # Returns array of all years we have bookings for
  def self.fiscal_years
    with_exclusive_scope do
      select("DISTINCT year(value_date) AS year").all.map{|booking| booking.year}
    end
  end

  # Standard methods
  def to_s(format = :default)
    case format
    when :long
      "%s: %s an %s CHF %s, %s (%s)" % [
        value_date ? value_date : '?',
        credit_account ? "#{credit_account.title} (#{credit_account.code})" : '?',
        debit_account ? "#{debit_account.title} (#{debit_account.code})" : '?',
        amount ? "%0.2f" % amount : '?',
        title.present? ? title : '?',
        comments.present? ? comments : '?'
      ]
    else
      "%s: %s / %s CHF %s" % [
        value_date ? value_date : '?',
        credit_account ? credit_account.code : '?',
        debit_account ? debit_account.code : '?',
        amount ? "%0.2f" % amount : '?',
      ]
    end
  end

  # Helpers
  def accounted_amount(account)
    if credit_account == account
      balance = -(amount)
    elsif debit_account == account
      balance = amount
    else
      return BigDecimal.new('0')
    end

    if account.is_asset_account?
      return -(balance)
    else
      return balance
    end
  end

  def amount_as_string
    '%0.2f' % amount
  end

  def amount_as_string=(value)
    self.amount = value
  end

  def rounded_amount
    if amount.nil?
    	return 0
    else
    	return (amount * 20).round / 20.0
    end
  end

  # Helpers
  def split(amount, params = {})
    # Clone
    new_booking = self.clone

    # Set amount
    new_booking[:amount] = amount
    self.amount -= amount

    # Update attributes
    params.each{|key, value|
      new_booking[key] = value
    }

    [self, new_booking]
  end

  # Reference
  belongs_to :reference, :polymorphic => true, :touch => true, :inverse_of => :bookings
  attr_accessible :reference_id, :reference_type, :reference

  after_save :touch_previous_reference
  def touch_previous_reference
    # TODO: support reference_type for polymorphic changes
    reference_id_changes = changes[:reference_id]
    if reference_id_changes && (previous_reference_id = reference_id_changes[0])
      previous_reference = reference_type.constantize.find(previous_reference_id)
      previous_reference.touch if previous_reference != reference
    end
  end

  after_save :notify_references
  after_destroy :notify_references

  # Safety net for form assignments
  def reference_type=(value)
    write_attribute(:reference_type, value) unless value.blank?
  end

  scope :by_reference, lambda {|value|
    where(:reference_id => value.id, :reference_type => value.class.base_class)
  } do
    # TODO duplicated in Invoice
    def direct_balance(direct_account)
      balance = 0.0

      for booking in all
        balance += booking.accounted_amount(direct_account)
      end

      balance
    end
  end

  private
  def notify_references
    return unless reference and reference.respond_to?(:booking_saved)
    reference.booking_saved(self)
  end
end
