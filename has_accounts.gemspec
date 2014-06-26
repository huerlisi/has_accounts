$:.unshift File.expand_path('../lib', __FILE__)
#
# Maintain your gem's version:
require 'has_accounts/version'

Gem::Specification.new do |s|
  s.name         = "has_accounts"
  s.version      = HasAccounts::VERSION
  s.authors      = ["Simon Huerlimann (CyT)"]
  s.email        = ["simon.huerlimann@cyt.ch"]
  s.homepage     = "https://github.com/huerlisi/has_accounts"
  s.summary      = "HasAccounts provides models for financial accounting."
  s.description  = "HasAccounts is a full featured Rails 3 gem providing models for financial accounting."
  s.licenses     = ["MIT"]

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency "rails", "> 3.1.0"
  s.add_dependency "inherited_resources"
  s.add_dependency "simple_form"
  s.add_dependency "i18n_rails_helpers"
  s.add_dependency "haml"
  s.add_dependency "validates_timeliness"
  s.add_dependency "has_vcards"
  s.add_dependency "acts-as-taggable-on"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pg"
  s.add_development_dependency "mysql2"

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'accepts_values_for'
end
