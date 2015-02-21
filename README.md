has_accounts
============

[![Build Status](https://secure.travis-ci.org/huerlisi/has_accounts.png)](http://travis-ci.org/huerlisi/has_accounts)

Rails plugin providing financal accounting models and helpers.


Install
=======

In Rails simply add to your Gemfile:

    gem 'has_accounts'

Integration
===========

Generate and run migrations

    rake has_accounts:install:migrations
    rake db:migrate

Seed basic account data

    AccountType.create!([
      {:name => "current_assets", :title => "Umlaufvermögen"},
      {:name => "capital_assets", :title => "Anlagevermögen"},
      {:name => "outside_capital", :title => "Fremdkapital"},
      {:name => "equity_capital", :title => "Eigenkapital"},
      {:name => "costs", :title => "Aufwand"},
      {:name => "earnings", :title => "Ertrag"},
    ])

Add specific seed depending on the needs of your project, e.g.:

    current_assets = AccountType.find_by_name('current_assets')
    capital_assets = AccountType.find_by_name('capital_assets')
    earnings = AccountType.find_by_name('earnings')
    costs = AccountType.find_by_name('costs')

    Account.create!([
      {:code => "1000", :title => "Kasse", :account_type => current_assets},
      {:code => "1100", :title => "Debitoren", :account_type => current_assets},
      {:code => "3200", :title => "Dienstleistungsertrag", :account_type => earnings},
      {:code => "3900", :title => "Debitorenverlust", :account_type => costs},
      {:code => "8000", :title => "Ausserordentlicher Ertrag", :account_type => earnings}
    ])


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

Released under the MIT license.
