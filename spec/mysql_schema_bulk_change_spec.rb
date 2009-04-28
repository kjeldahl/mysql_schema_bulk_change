require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'mysql_schema_bulk_change' do
  def connection
    ActiveRecord::Base.connection
  end
  
  before(:each) do
      ActiveRecord::Migration.verbose = true
      begin
        connection.tables.each do |table|
          connection.drop_table(table)
        end
      rescue
      end
      connection.create_table :test_table do |t|
        t.string :name
      end
      connection.add_index :test_table, :name
  end
  after(:each) do
    begin
      connection.tables.each do |table|
        connection.drop_table(table)
      end
    rescue
    end
  end 
  
  it "should not call the connection adapter in the block" do
    connection.should_not_receive(:add_column)    
    connection.should_not_receive(:add_index)
    connection.should_receive(:execute).with("ALTER TABLE `test_table` ADD `author` varchar(255), ADD  INDEX `index_test_table_on_author`(`author`), DROP INDEX `index_test_table_on_name`")
    connection.change_table :test_table do |t|
      t.string :author
      t.index :author
      t.remove_index :name
    end
  end
  
end
