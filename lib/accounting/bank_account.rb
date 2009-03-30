module Accounting
  class BankAccount < Account
    belongs_to :bank
    belongs_to :holder_vcard, :class_name => 'Vcards::Vcard', :foreign_key => 'holder_vcard_id'
  end
end
