has_accounts
============

Rails plugin providing financal accounting models and helpers.


Install
=======

In Rails 3 simply add

  gem 'has_accounts'


Example
=======

There is a new class method made available to ActiveRecord::Base
by this plugin:

* has_accounts(options = {})

Use it like this:

class Doctor < ActiveRecord::Base
  has_vcards
end

License
=======

Copyright (c) 2008 Agrabah <http://www.agrabah.ch>
Copyright (c) 2008-2011 Simon Hürlimann <simon.huerlimann@cyt.ch>
Copyright (c) 2010-2011 CyT <http://www.cyt.ch>
Copyright (c) 2008-2010 ZytoLabor <http://www.zyto-labor.com>

Released under the MIT license.