# Include hook code here
require 'accounting/account'

ActiveRecord::Base.extend(Accounting::ClassMethods)
