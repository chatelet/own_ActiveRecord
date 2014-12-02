require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...params is {}
    where_line = params.keys.map {|el| el.to_s + " = ?"}.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    #SQL returns array of hashes, we need to process it 
    parse_all(results)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
