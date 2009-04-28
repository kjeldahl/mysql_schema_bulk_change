require 'active_record'
require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    # The MysqlBulkProxy will collect changes to a Mysql table definition and execute them all in one
    # SQL statement
    class MysqlBulkProxy
      def initialize(table_name, base)
        @table_name = table_name
        @base = base
        @statements = []
      end
      
      def add_column(table_name, column_name, type, options = {})
        check_table_name(table_name)
        alter_specification = "ADD #{@base.quote_column_name(column_name)} #{@base.type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
        @base.add_column_options!(alter_specification, options)
        add_stmt(alter_specification)
      end
      
      def add_index(table_name, column_name, options = {})
        check_table_name(table_name)
        column_names = Array(column_name)
        index_name   = @base.index_name(@table_name, :column => column_names)

        if Hash === options # legacy support, since this param was a string
          index_type = options[:unique] ? "UNIQUE" : ""
          index_name = options[:name] || index_name
        else
          index_type = options
        end
        quoted_column_names = column_names.map { |e| @base.quote_column_name(e) }.join(", ")
        add_stmt("ADD #{index_type} INDEX #{@base.quote_column_name(index_name)}(#{quoted_column_names})")
      end
      
      def add_timestamps(table_name)
        check_table_name(table_name)
        add_column table_name, :created_at, :datetime
        add_column table_name, :updated_at, :datetime
      end
      
      def remove_timestamps(table_name)
        remove_column table_name, :updated_at
        remove_column table_name, :created_at
      end
      
      def change_column(table_name, column_name, type, options = {})
        check_table_name(table_name)
        column = @base.column_for(@table_name, column_name)

        unless @base.options_include_default?(options)
          options[:default] = column.default
        end

        unless options.has_key?(:null)
          options[:null] = column.null
        end

        change_column_sql = "CHANGE #{@base.quote_column_name(column_name)} #{@base.quote_column_name(column_name)} #{@base.type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
        @base.add_column_options!(change_column_sql, options)
        add_stmt(change_column_sql)
      end

      def change_column_default(table_name, column_name, default) #:nodoc:
        check_table_name(table_name)
        column = @base.column_for(@table_name, column_name)
        change_column(@table_name, column_name, column.sql_type, :default => default)
      end

      def rename_column(table_name, column_name, new_column_name) #:nodoc:
        check_table_name(table_name)
        options = {}
        if column = @base.columns(table_name).find { |c| c.name == column_name.to_s }
          options[:default] = column.default
          options[:null] = column.null
        else
          raise ActiveRecordError, "No such column: #{table_name}.#{column_name}"
        end
        current_type = @base.select_one("SHOW COLUMNS FROM #{quote_table_name(table_name)} LIKE '#{column_name}'")["Type"]
        rename_column_sql = "CHANGE #{quote_column_name(column_name)} #{quote_column_name(new_column_name)} #{current_type}"
        @base.add_column_options!(rename_column_sql, options)
        add_stmt(rename_column_sql)
      end

      def remove_column(table_name, *column_names)
        add_stmts(column_names.flatten.map { |column_name| "DROP COLUMN #{@base.quote_column_name(column_name)}"})
      end
      alias_method :remove_columns, :remove_column
      
      def remove_index(table_name, options = {})
        check_table_name(table_name)
        add_stmt("DROP INDEX #{@base.quote_column_name(@base.index_name(@table_name, options))}")
      end
       
       def type_to_sql(type, limit = nil, precision = nil, scale = nil)
         @base.type_to_sql(type, limit, precision, scale)
       end
                  
      # Commits the updates to the database and clears the cached statements
      def update_database
        unless @statements.empty?
          alter_table_sql = "ALTER TABLE #{@base.quote_table_name(@table_name)}"
          result = @base.execute(alter_table_sql + " " + @statements.join(', '))
          @statements.clear
          result
        end
      end

      def native
        @base.native_database_types
      end
      alias_method :native_database_types, :native
       
      private
      def check_table_name(table_name)
        raise "Tablename mismatch expected '#{@table_name}', but got '#{table_name}'" unless @table_name == table_name
      end
      
      def add_stmt(*stmt)
        @statements += stmt.flatten
      end
      alias :add_stmts :add_stmt
      
      def method_missing(symbol, *args)
        @base.send symbol, *args
      end
      
    end
    
    class MysqlAdapter < AbstractAdapter
      # Changed to return a proxy for collecting the changes and do bulk updates
      alias_method :change_table_direct, :change_table
      def change_table(table_name)
        bulk_updater = MysqlBulkProxy.new(table_name, self)
        yield Table.new(table_name, bulk_updater)
        bulk_updater.update_database
      end  
    end
  end
end