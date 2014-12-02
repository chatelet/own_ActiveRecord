require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    if @columns
      return @columns
    end
    sql = "SELECT * FROM #{self.table_name}"
    #ways to call SQL lanuage
    result = DBConnection.execute2(sql)[0]
    #result.map!(&:to_sym) #change it to sym
    @columns = result.map! {|el| el.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  # using pluralize instead of tableize(belongs to ActiveRecord, not regular ruby)
  def self.table_name
    # ...
    if @table_name == nil
      self.name.downcase.pluralize
    else
      @table_name
    end
  end

  def self.all
    # ...
    sql = "SELECT #{table_name}.* FROM #{table_name}"
    results = DBConnection.execute(sql)
    parse_all(results)
    # results = DBConnection.execute(<<-SQL)
    #   SELECT
    #   #{ table_name }.*
    #   FROM
    #   #{ table_name }
    # SQL
    #
    # parse_all(results)
  end

  def self.parse_all(results)
    # ...
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    # ...
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    # ...
    params.each do |key, value|
      key_sym = key.to_sym
      raise "unknown attribute '#{key_sym}'" unless self.class.columns.include?(key_sym)
      self.send("#{key_sym}=", value)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    # ...
    col_names = self.class.columns.map(&:to_s).join(",")
    question_marks = (["?"] * self.class.columns.count).join(",")

    #beware of the insertion format, like (col1, col2,....)
    result = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
    #update the id
  end

  def update
    # ...
    # col_names = self.class.columns.map do |el|
    #   el.to_s + " = ?"
    # end
    # col_names = col_names.join(",")

    col_names = self.class.columns.map {|el| el.to_s + " = ?"}.join(",")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    # ...
    if self.id
      update
    else
      insert
    end
  end
end
