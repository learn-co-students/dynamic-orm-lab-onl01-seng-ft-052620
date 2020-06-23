require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

    # Initialize
    def initialize(options={})
        options.each do |param,val|
            send("#{param}=",val)
        end
    end

    # table name
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def table_name_for_insert
        self.class.table_name
    end

    # column names
    def self.column_names
        DB[:conn].execute("PRAGMA table_info(#{self.table_name})").map do |col|
            col["name"]
        end.compact
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|col| col=="id"}.join(", ")
    end

    # values for insert
    def values_for_insert
        self.class.column_names.delete_if {|col| col=="id"}.map do |col|
            "'#{self.send("#{col}")}'"
        end.join(", ")
    end

    # saving 
    def save
       # binding.pry

        sql=<<-SQL
        INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
        VALUES (%s)
        SQL

        DB[:conn].execute(sql % [self.values_for_insert])
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
        self
    end

    # finding

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1",[name])
    end

    def self.find_by(options)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{self.options_for_find(options)} LIMIT 1")
    end
    
    def self.options_for_find(options)
        # format for option1 = val1
        options.map do |param,val|
            "#{param}='#{val}'"
        end.join(" AND ")
    end

end