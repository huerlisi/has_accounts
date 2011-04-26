# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "has_accounts"
  s.summary = "HasAccounts provides models for financial accounting."
  s.authors = ["Simon Hürlimann (CyT)"]
  s.email = ["simon.huerlimann@cyt.ch"]
  s.description = "HasAccounts is a full featured Rails 3 gem providing models for financial accounting."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.version = "0.6.1"
end
