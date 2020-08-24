require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names

    column_names = []


    sql = "PRAGMA table_info('#{table_name}')" 
    table_info = DB[:conn].execute(sql)

    table_info.each do |col| 
      column_names << col["name"] #this gives you the value for the key "name"
    end
    column_names.compact 
  end


  def initialize(options = {}) 
    options.each do |key,value|
      self.send(("#{key}="),value)
    end
  end

  def table_name_for_insert

    self.class.table_name
  end

  def col_names_for_insert
  
    self.class.column_names.delete_if {|column_name| column_name == "id"}.join (", ")
  end

  def values_for_insert
   
    values_array = []
    self.class.column_names.each do |column_name|

      values_array << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    values_array.join(", ")
  end

  def save
    #insert data into db #save saves the student to the db
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    row = DB[:conn].execute(sql,name)
  end

  def self.find_by(attribute)

    sql =<<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute_key} = "#{attrubute_value}"
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql)
  end

    def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end
  


  
end