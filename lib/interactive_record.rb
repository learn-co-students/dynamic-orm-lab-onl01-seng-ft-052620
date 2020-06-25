require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(attrs = {})
  	attrs.each{|k,v| self.send("#{k}=", v) unless k == :id}
  end

  def self.table_name
  	self.to_s.downcase.pluralize
  end

  def self.column_names
  	sql = "PRAGMA table_info(#{self.table_name});"
  	DB[:conn].execute(sql).map{|col_hash| col_hash["name"]}
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}';"
  	DB[:conn].execute(sql)
  	#[DB[:conn].execute(sql)[0].delete_if{|k,v| !self.column_names.include?(k)}]
  end

  def self.find_by(attr_hash)
  	sql = "SELECT * FROM #{self.table_name} WHERE #{attr_hash.keys[0]} = '#{attr_hash.values[0]}';"
  	DB[:conn].execute(sql)
  end

  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	sql = "PRAGMA table_info(#{self.table_name_for_insert});"
  	DB[:conn].execute(sql).map{|col_hash| col_hash["name"] unless col_hash["name"] == "id"}.compact.join(", ")
  end

  def values_for_insert
  	self.col_names_for_insert.split(", ").map{|col| "'" + self.send(col).to_s + "'"}.join(", ")
  end

  def save
  	sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert});"
  	DB[:conn].execute(sql)
  	self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end


end