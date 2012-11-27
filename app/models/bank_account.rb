class BankAccount < Account
  # Access restrictions
  attr_accessible :pc_id, :esr_id, :bank_id

  belongs_to :bank
end
