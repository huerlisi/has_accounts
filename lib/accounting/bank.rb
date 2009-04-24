module Accounting
  class Bank < ActiveRecord::Base
    has_many :accounts

    has_vcards
  end
end
