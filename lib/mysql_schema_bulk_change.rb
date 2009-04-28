$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module MysqlSchemaBulkChange
  VERSION = '0.2.0'
end

require 'mysql_schema_bulk_change/mysql_adapter'