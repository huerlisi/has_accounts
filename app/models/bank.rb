class Bank < ActiveRecord::Base
  has_many :bank_accounts

  has_vcards

  def to_s
    return "" unless vcard

    [vcard.full_name, vcard.locality].compact.join(', ')      
  end
end
