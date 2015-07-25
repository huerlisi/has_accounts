class Booking < ActiveRecord::Base
  # Access restrictions
  attr_accessible :title, :comments, :amount, :value_date, :code

  # Validation
  validates_presence_of :debit_account, :credit_account, :title, :value_date
  validates :amount, presence: true, numericality: true
  validates_time :value_date

  # Template
  belongs_to :template, polymorphic: true

  # Account
  belongs_to :debit_account, foreign_key: 'debit_account_id', class_name: 'Account'
  attr_accessible :debit_account, :debit_account_id
  belongs_to :credit_account, foreign_key: 'credit_account_id', class_name: 'Account'
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
    return credit_account if credit_account.balance_account?
    return debit_account if debit_account.balance_account?
  end

  def profit_account
    return credit_account if credit_account.profit_account?
    return debit_account if debit_account.profit_account?
  end

  # Scoping
  default_scope order('value_date, id')

  # Scope filter for date range
  scope :by_date_period, lambda {|date_from, date_to|
    if date_from.present? && date_to.present?
      where(:value_date => date_from..date_to)
    elsif date_from.present?
      where('value_date >= ?', date_from)
    elsif date_to.present?
      where('value_date <= ?', date_to)
    end
  }

  # Scope for date filter
  #
  # @param from [Date]
  # @param to [Date]
  scope :by_date, lambda {|*args|
    dates = args.map do |date|
      begin
        date.to_date
      rescue
        nil
      end
    end

    if dates.count == 0
      scoped
    elsif dates.count == 1
      where(:value_date => dates[0])
    elsif dates.count == 2
      by_date_period(dates[0], dates[1])
    end
  }

  # Scope for amount range filter
  scope :by_amount_range, lambda {|amount_from, amount_to|
    if amount_from.present? && amount_to.present?
      where(:amount => amount_from..amount_to)
    elsif amount_from.present?
      where('amount >= ?', amount_from)
    elsif amount_to.present?
      where('amount <= ?', amount_to)
    end
  }

  # Scope for amount filter
  scope :by_amount, lambda {|*args|
    if args.count == 0
      scoped
    elsif args.count == 1
      where(:amount => args[0])
    elsif args.count == 2
      by_amount_range(args[0], args[1])
    end
  }

  # Scope for all accounts assigned to account
  #
  # @param account_id [Integer]
  scope :by_account, lambda {|account_id|
    where('debit_account_id = :account_id OR credit_account_id = :account_id', account_id: account_id)
  } do
    # Returns array of all booking titles.
    def titles
      find(:all, group: :title).map(&:title)
    end

    # Statistics per booking title.
    #
    # The statistics are an array of hashes with keys title, count, sum, average.
    def statistics
      find(:all, select: 'title, count(*) AS count, sum(amount) AS sum, avg(amount) AS avg', group: :title).map(&:attributes)
    end
  end

  # All involved accounts
  #
  # @returns all involved credit and debit accounts
  def self.accounts
    Account.where(id: pluck(:debit_account_id).uniq + pluck(:credit_account_id).uniq)
  end

  # Accounts with balances
  #
  # @returns [Hash] with involved accounts as keys and balances as values
  def self.balances
    account_balances = accounts.map do |account|
      [account, balance_by(account)]
    end

    Hash[account_balances]
  end

  # Accounted bookings
  # ==================
  SELECT_ACCOUNTED_AMOUNT = 'CASE WHEN credit_account_id = debit_account_id THEN 0.0 WHEN credit_account_id = %{account_id} THEN -bookings.amount WHEN debit_account_id = %{account_id} THEN bookings.amount ELSE 0 END'

  private

  def self.get_account_id(account_or_id)
    if account_or_id.is_a? Account
      return account_or_id.id
    elsif Account.exists?(account_or_id)
      return account_or_id
    else
      raise ActiveRecord::RecordNotFound, 'argument needs to be a record of type Account or an id for an existing Account record.'
    end
  end

  public

  # Scope where booking amounts are signed according to debit or credit side
  #
  # @param account_or_id Account id or object
  scope :accounted_by, lambda {|account_or_id|
    select("bookings.*, #{SELECT_ACCOUNTED_AMOUNT % { account_id: get_account_id(account_or_id) }} AS amount")
  }

  # Balance of bookings for the specified account
  #
  # @param account_or_id Account id or object
  def self.balance_by(account_or_id)
    BigDecimal.new(sum(SELECT_ACCOUNTED_AMOUNT % { account_id: get_account_id(account_or_id) }), 2)
  end

  # Balance of bookings for the specified account with 0 balance, grouped by reference
  #
  # @param account_or_id Account id or object
  def self.unbalanced_by_grouped_reference(account_or_id)
    # Do a manual sum using select() to be able to give it an alias we can use in having()
    balance_select = "sum(#{SELECT_ACCOUNTED_AMOUNT % { account_id: get_account_id(account_or_id) }})"
    summs = group(:reference_type, :reference_id).having("#{balance_select} != 0.0").select("reference_type, reference_id, #{balance_select} AS balance").reorder(nil)

    # Simulate Rails grouped summing result format
    grouped = Hash[summs.map { |group| [[group[:reference_type], group[:reference_id]], group[:balance]] }]

    # Convert value to BigDecimal
    Hash[grouped.map { |reference, value| [reference, BigDecimal.new(value, 2)] }]
  end

  # Balance of bookings for the specified account, grouped by reference
  #
  # @param account_or_id Account id or object
  def self.balance_by_grouped_reference(account_or_id)
    grouped = group(:reference_type, :reference_id).sum(SELECT_ACCOUNTED_AMOUNT % { account_id: get_account_id(account_or_id) })

    # Convert value to BigDecimal
    Hash[grouped.map { |reference, value| [reference, BigDecimal.new(value, 2)] }]
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

    where('title ILIKE :text OR comments ILIKE :text OR amount = :amount OR value_date = :value_date', text: text, amount: amount, value_date: date)
  }

  # Returns array of all years we have bookings for
  def self.fiscal_years
    with_exclusive_scope do
      select('DISTINCT year(value_date) AS year').all.map(&:year)
    end
  end

  # Standard methods
  def to_s(format = :default)
    case format
    when :long
      '%s: %s an %s CHF %s, %s (%s)' % [
        value_date ? value_date : '?',
        debit_account ? "#{debit_account.title} (#{debit_account.code})" : '?',
        credit_account ? "#{credit_account.title} (#{credit_account.code})" : '?',
        amount ? '%0.2f' % amount : '?',
        title.present? ? title : '?',
        comments.present? ? comments : '?'
      ]
    else
      '%s: %s / %s CHF %s' % [
        value_date ? value_date : '?',
        debit_account ? debit_account.code : '?',
        credit_account ? credit_account.code : '?',
        amount ? '%0.2f' % amount : '?'
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

    if account.asset_account?
      return balance
    else
      return -(balance)
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
    new_booking = clone

    # Set amount
    new_booking[:amount] = amount
    self.amount -= amount

    # Update attributes
    params.each do|key, value|
      new_booking[key] = value
    end

    [self, new_booking]
  end

  # Reference
  belongs_to :reference, polymorphic: true, touch: true, inverse_of: :bookings
  attr_accessible :reference_id, :reference_type, :reference

  after_save :touch_previous_reference
  def touch_previous_reference
    # TODO: support reference_type for polymorphic changes
    reference_id_changes = changes[:reference_id]
    if reference_id_changes && (previous_reference_id = reference_id_changes[0])
      # Guard against disappeared previous reference
      begin
        previous_reference = reference_type.constantize.find(previous_reference_id)
        previous_reference.touch if previous_reference != reference
      rescue
      end
    end
  end

  after_save :notify_references
  after_destroy :notify_references

  # Safety net for form assignments
  def reference_type=(value)
    write_attribute(:reference_type, value) unless value.blank?
  end

  scope :by_reference, lambda {|value|
    where(reference_id: value.id, reference_type: value.class.base_class)
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
    return unless reference && reference.respond_to?(:booking_saved)
    reference.booking_saved(self)
  end
end
