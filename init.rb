# Include hook code here
require 'accounting/account'

ActiveRecord::Base.extend(Accounting::ClassMethods)

require 'accounting/core_ext/float'
