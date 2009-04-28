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
        raise "Tablename mismatch expected '#{@table_name}', but got '#{table_name}'" unless @table_name == table_name
        column(column_name, type, options)
      end
      
      def column(column_name, type, options = {})
        alter_specification = "ADD #{@base.quote_column_name(column_name)} #{@base.type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
        @base.add_column_options!(alter_specification, options)
        add_stmt(alter_specification)
      end
      
      def add_index(table_name, column_name, options)
        raise "Tablename mismatch expected '#{@table_name}', but got '#{table_name}'" unless @table_name == table_name
        index(column_name, options)
      end
      
      def index(column_name, options = {})
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
       
      def remove(*column_names)
        add_stmts(column_names.flatten.map { |column_name| "DROP COLUMN #{@base.quote_column_name(column_name)}"})
      end
      
      def remove_index(table_name, options = {})
        raise "Tablename mismatch expected '#{@table_name}', but got '#{table_name}'" unless @table_name == table_name
        add_stmt("DROP INDEX #{@base.quote_column_name(@base.index_name(@table_name, options))}")
      end
            
      # Adds a column or columns of a specified type
      # ===== Examples
      #  t.string(:goat)
      #  t.string(:goat, :sheep)
      %w(string text integer float decimal datetime timestamp time date binary boolean ).each do |column_type|
        class_eval %{
          def #{column_type}(*args)                                          # def string(*args)
            options = args.extract_options!                                  #   options = args.extract_options!
            column_names = args                                              #   column_names = args
                                                                             #
            column_names.each do |name|                                      #   column_names.each do |name|
              column = ColumnDefinition.new(@base, name, '#{column_type}')   #     column = ColumnDefinition.new(@base, name, 'string')
              if options[:limit]                                             #     if options[:limit]
                column.limit = options[:limit]                               #       column.limit = options[:limit]
              elsif self.native['#{column_type}'.to_sym].is_a?(Hash)         #     elsif native['string'.to_sym].is_a?(Hash)
                column.limit = self.native['#{column_type}'.to_sym][:limit]  #       column.limit = native['string'.to_sym][:limit]
              end                                                            #     end
              column.precision = options[:precision]                         #     column.precision = options[:precision]
              column.scale = options[:scale]                                 #     column.scale = options[:scale]
              column.default = options[:default]                             #     column.default = options[:default]
              column.null = options[:null]                                   #     column.null = options[:null]
              column(name, column.sql_type, options)                         #     column(name, column.sql_type, options)
            end                                                              #   end
          end                                                                # end
        } , __FILE__, __LINE__
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
       
      private
      def add_stmt(*stmt)
        @statements + stmt.flatten
      end
      alias :add_stmts :add_stmt
      
      def method_missing(symbol, *args)
        #puts "Missing: #{symbol} called from \n#{Kernel.caller.join("\n")}"
        update_database # Need to flush the cache in case some of the cached columns are required in the
                        # SQL about to be executed
        @base.send symbol, *args
      end
      
    end
    
    class MysqlAdapter < AbstractAdapter
      # Changed to return a proxy for collecting the changes and do bulk updates
      def change_table(table_name)
        bulk_updater = MysqlBulkProxy.new(table_name, self)
        yield Table.new(table_name, bulk_updater)
        bulk_updater.update_database
      end      
    end
  end
end