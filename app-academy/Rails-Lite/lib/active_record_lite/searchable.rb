require_relative './db_connection'

module Searchable
  def where(params)
    conditionals = params.keys.map { |key| "#{key} = ?" }

    rows = DBConnection.execute(<<-SQL, *params.values)
      SELECT *
      FROM #{self.table_name}
      WHERE #{conditionals.join(' AND ')}
    SQL

    self.parse_all(rows)
  end
end