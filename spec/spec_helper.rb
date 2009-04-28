begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end
require 'rubygems'
gem 'rails', '= 2.3.2'
require 'active_record'

$:.unshift(File.dirname(__FILE__) + '/../lib')

# Setup database connection piggy back on rails' unit test database

require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

# GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
# GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';

ActiveRecord::Base.configurations = {
  'arunit' => {
    :adapter  => 'mysql',
    :username => 'rails',
    :encoding => 'utf8',
    :database => 'activerecord_unittest',
  }}

ActiveRecord::Base.establish_connection 'arunit'

require 'mysql_schema_bulk_change'
