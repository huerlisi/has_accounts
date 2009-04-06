module Accounting
  class BankAccount < Account
    belongs_to :bank
  end
end
