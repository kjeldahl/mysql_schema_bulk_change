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

require 'logger'

def runcoderun?
  ENV["RUN_CODE_RUN"]
end

ActiveRecord::Base.logger = Logger.new("debug.log")

db_user = runcoderun? ? 'build' : 'root'

ActiveRecord::Base.configurations = {
  'test_db' => {
    :adapter  => 'mysql',
    :username => db_user,
    :encoding => 'utf8',
    :database => 'kjeldahl_mysql_schema_bulk_change_test',
  }}

ActiveRecord::Base.establish_connection 'test_db'

require 'mysql_schema_bulk_change'
