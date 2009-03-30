require 'fileutils'

# Copy the db migration scripts into RAILS_ROOT/db/migrate
FileUtils.mkdir( File.join(RAILS_ROOT, 'db/migrate') ) unless FileTest.exist? File.join(RAILS_ROOT, 'db/migrate')
 
FileUtils.cp(
 Dir[File.join(File.dirname(__FILE__), 'db/migrate/*.rb')], File.join(RAILS_ROOT, 'db/migrate'), :verbose => true
)
