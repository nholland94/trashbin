require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_accessor :other_class_name, :primary_key, :foreign_key, :name

  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @name = name

    default_other_class_name = name.to_s.downcase.camelcase
    @other_class_name = params[:class_name] || default_other_class_name
    

    default_primary_key = "id"
    @primary_key = params[:primary_key] || default_primary_key

    default_foreign_key =  "#{@other_class_name}_id"
    @foreign_key = params[:foreign_key] || default_foreign_key
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @name = name

    default_other_class_name = name.to_s.downcase.singularize.camelcase
    @other_class_name = params[:class_name] || default_other_class_name
    
    default_primary_key = "id"
    @primary_key = params[:primary_key] || default_primary_key

    default_foreign_key = "#{self_class.to_s.downcase.underscore}_id"
    @foreign_key = params[:foreign_key] || default_foreign_key
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def correct_pluralize(class_name)
    if class_name != "human"
        id_class = class_name.pluralize
      else
        id_class = "#{class_name}s"
      end
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)

    define_method(name) do
      #pluralize tries to make "human" => "humen"
      id_class = self.class.correct_pluralize(self.class.to_s.downcase)
      
      results = DBConnection.execute(<<-SQL)
        SELECT #{aps.other_class.table_name}.*
        FROM #{self.class.table_name}
        INNER JOIN #{aps.other_class.table_name}
        ON #{aps.foreign_key} = #{id_class}.#{aps.primary_key}
      SQL

      aps.other_class.parse_all(results).first
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)

    define_method(name) do
      id_class = self.class.correct_pluralize(aps.other_class_name.downcase.underscore)
      
      results = DBConnection.execute(<<-SQL)
        SELECT #{aps.other_class.table_name}.*
        FROM #{self.class.table_name}
        INNER JOIN #{aps.other_class.table_name}
        ON #{aps.foreign_key} = #{id_class}.#{aps.primary_key}
      SQL

      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name) do
      id_class1 = self.class.correct_pluralize(self.class.to_s.downcase)
      id_class2 = self.class.correct_pluralize(assoc1.class.to_s.downcase)

      results = DBConnection.execute(<<-SQL)
        SELECT #{assoc2.other_class.table_name}.*
        FROM #{self.class.table_name}
        INNER JOIN #{assoc1.other_class.table_name}
        ON #{assoc1.foreign_key} = #{id_class1}.#{assoc1.primary_key}
        INNER JOIN #{assoc2.other_class.table_name}
        ON #{assoc2.foreign_key} = #{id_class2}.#{assoc2.primary_key}
      SQL

      assoc2.other_class.parse_all(results).first
    end
  end
end