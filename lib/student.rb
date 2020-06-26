require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
    column_names << column["name"]
    end

     column_names
  end

  self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end

  def initialize(hash = {})
    hash.each do |key, value|
     self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|element| element == "id"}
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

def self.find_by_name(name)
  sql = <<-SQL
  select *
  FROM students
  WHERE students.name = ?
  SQL

  row = DB[:conn].execute(sql, name).flatten

end

def self.find_by(name: nil, grade: nil, id: nil)
  row = nil
  this_name = name
  this_grade = grade
  thi_id = id
  if this_name
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE students.name = ?
    SQL

    row = DB[:conn].execute(sql, this_name)
  elsif this_grade
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE students.grade = ?
    SQL

    row = DB[:conn].execute(sql, this_grade)
  else
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE students.id = ?
    SQL

    row = DB[:conn].execute(sql, this_id)
  end
  row
  end

end 
