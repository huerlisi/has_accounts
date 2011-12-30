has_accounts
============

[![Build Status](https://secure.travis-ci.org/huerlisi/has_accounts.png)](http://travis-ci.org/huerlisi/has_accounts)

Rails plugin providing financal accounting models and helpers.


Install
=======

In Rails 3 simply add

    gem 'has_accounts'


Example
=======

A few models are available:

    class Booking
    class Account
    class AccountType

There's also a ready to use module available to attach accountable
functionality to existing models.

To use it, simply add the following to your Model:

    include HasAccounts::Model


License
=======

* Copyright (c) 2008 Agrabah <http://www.agrabah.ch>
* Copyright (c) 2008-2011 Simon Hürlimann <simon.huerlimann@cyt.ch>
* Copyright (c) 2010-2011 CyT <http://www.cyt.ch>
* Copyright (c) 2008-2010 ZytoLabor <http://www.zyto-labor.com>

Released under the MIT license.
