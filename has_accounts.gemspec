# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'has_accounts/version'

Gem::Specification.new do |s|
  s.name         = "has_accounts"
  s.version      = HasAccounts::VERSION
  s.authors      = ["Simon Hürlimann (CyT)"]
  s.email        = ["simon.huerlimann@cyt.ch"]
  s.homepage     = "https://github.com/huerlisi/has_accounts"
  s.summary      = "HasAccounts provides models for financial accounting."
  s.description  = "HasAccounts is a full featured Rails 3 gem providing models for financial accounting."

  s.files        = `git ls-files app lib config`.split("\n")
  s.platform     = Gem::Platform::RUBY

  s.extra_rdoc_files = ["README.md"]
end
