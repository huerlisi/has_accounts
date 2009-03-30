module Accounting
  class Bank < ActiveRecord::Base
    has_many :accounts

    belongs_to :vcard, :class_name => 'Vcards::Vcard'
  end
end
