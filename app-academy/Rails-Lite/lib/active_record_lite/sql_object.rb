require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    self.parse_all(rows)
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
    SQL

    return nil if row.nil?

    new(row.first)
  end

  def create
    DBConnection.execute(<<-SQL, *self.attributes.values)
      INSERT INTO #{self.table_name}
      #{self.attributes.keys.join(' ')}
      VALUES
      #{(['?'] * self.class.attributes.length).join(', ')}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_hash = {}

    self.class.attributes.each do |attribute|
      value = self.send(attribute)

      unless value.nil? || attribute == :id
        attr_hash[attribute] = value
      end
    end

    DBConnection.execute(<<-SQL, *attr_hash.values)
      UPDATE #{self.class.table_name}
      SET
      #{attr_hash.keys.join(' = ?, ')} = ?
    SQL
  end

  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  def attribute_values
  end
end
