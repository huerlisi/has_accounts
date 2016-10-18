# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'has_accounts/version'

Gem::Specification.new do |s|
  # Description
  s.name         = 'has_accounts'
  s.version      = HasAccounts::VERSION
  s.summary      = 'HasAccounts provides models for financial accounting.'
  s.description  = 'HasAccounts is a full featured Rails gem providing models for financial accounting.'

  s.homepage     = 'https://github.com/huerlisi/has_accounts'
  s.authors      = ['Simon Hürlimann (CyT)']
  s.email        = ['simon.huerlimann@cyt.ch']
  s.licenses     = ['MIT']

  # Files
  s.extra_rdoc_files = [
    'MIT-LICENSE',
    'README.md'
  ]

  s.files        = `git ls-files app lib config db`.split("\n")

  s.platform     = Gem::Platform::RUBY

  # Dependencies
  s.add_runtime_dependency('rails', ['> 3.1'])
  s.add_runtime_dependency('validates_timeliness')
end
