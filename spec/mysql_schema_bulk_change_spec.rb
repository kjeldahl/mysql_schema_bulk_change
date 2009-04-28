require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe 'mysql_schema_bulk_change' do
  before(:each) do
      ActiveRecord::Migration.verbose = true
      begin
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.drop_table(table)
        end
      rescue
      end
      ActiveRecord::Base.connection.create_table :test_table do |t|
        t.string :name
      end
      ActiveRecord::Base.connection.add_index :test_table, :name
  end
  after(:each) do
    #ActiveRecord::Base.connection.initialize_schema_migrations_table
    #ActiveRecord::Base.connection.execute "DELETE FROM #{ActiveRecord::Migrator.schema_migrations_table_name}"
    begin
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    rescue
    end
  end 
  
  it "should not call the connection adapter in the block" do
    ActiveRecord::Base.connection.should_not_receive(:add_column)    
    ActiveRecord::Base.connection.should_not_receive(:add_index)
    ActiveRecord::Base.connection.should_receive(:execute)
    ActiveRecord::Base.connection.change_table :test_table do |t|
      t.string :author
      t.index :author
    end
  end
  
end
