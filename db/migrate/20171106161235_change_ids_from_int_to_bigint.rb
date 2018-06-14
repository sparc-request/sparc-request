class ChangeIdsFromIntToBigint < ActiveRecord::Migration[5.1]
  def change
    #### This needs to be defined because of the order of migrations ####
    class PermissibleValue < ApplicationRecord

      # Get the first PermissibleValue value using a category and key
      def self.get_value(category, key)
        PermissibleValue.where(category: category, key: key).first.try(:value)
      end

      # Get an array of PermissibleValue keys with the given category
      def self.get_key_list(category, default=nil)
        unless default.nil?
          PermissibleValue.where(category: category, default: default).pluck(:key)
        else
          PermissibleValue.where(category: category).pluck(:key)
        end
      end

      # Get a hash of PermissibleValue keys as they keys and values as values
      def self.get_hash(category, default=nil)
        unless default.nil?
          Hash[PermissibleValue.where(category: category, default: default).pluck(:key, :value)]
        else
          Hash[PermissibleValue.where(category: category).pluck(:key, :value)]
        end
      end

      # Get a hash of PermissibleValue values as the keys and keys as values
      def self.get_inverted_hash(category, default=nil)
        unless default.nil?
          Hash[PermissibleValue.where(category: category, default: default).pluck(:value, :key)]
        else
          Hash[PermissibleValue.where(category: category).pluck(:value, :key)]
        end
      end
    end
    #### end model override ####

    db_models, db_habtms = map_models_to_tablenames
    non_ar_tables = (ActiveRecord::Base.connection.tables - db_models.keys - db_habtms)
    references = Hash.new{ |h, k| h[k] = [] }
    foreign_keys = Hash.new{ |h, k| h[k] = [] }
    ActiveRecord::Base.transaction do

      db_models.except("documents").each do |table_name, model|
        fks = foreign_keys(table_name)
        foreign_keys[table_name] = fks if fks.present?
        references[table_name] = get_references(model) unless get_references(model).empty?
      end

      foreign_keys.each do |table_name, fks|
        fks.each do |foreign_key|
          remove_foreign_key table_name, name: foreign_key.name
        end
      end

      db_models.each do |table_name, model|
        change_column table_name, model.primary_key, :bigint, auto_increment: true if column_is_integer? model, model.primary_key
      end

      references.each do |table_name, references|
        references.each do |column_name|
          change_column table_name, column_name, :bigint
        end
      end

      foreign_keys.each do |table_name, fks|
        fks.each do |foreign_key|
          add_foreign_key table_name, foreign_key.to_table, column: foreign_key.column, primary_key: foreign_key.primary_key
        end
      end

      db_habtms.each do |table_name|
        columns = columns(table_name)
        columns.each do |column|
          change_column table_name, column.name, :bigint if column.type == :integer
        end
      end

      non_ar_tables.each do |table_name|
        sql_result = ActiveRecord::Base.connection.exec_query("SHOW COLUMNS FROM #{table_name}")
        key_index = sql_result.columns.find_index("Key")
        type_index = sql_result.columns.find_index("Type")
        name_index = sql_result.columns.find_index("Field")
        reference_columns = sql_result.rows.select{ |row| row[key_index].present? }
        reference_columns.each do |column|
          change_column table_name, column[name_index], :bigint if column[type_index] == "int(11)"
        end
      end
    end
  end

  def map_models_to_tablenames
    Rails.application.eager_load!

    tables = ActiveRecord::Base.connection.tables
    models = ActiveRecord::Base.descendants
    db_habtms = models.map{ |model| model.reflect_on_all_associations(:has_and_belongs_to_many) }.compact.flatten.map{ |reflection| reflection.join_table }.uniq
    db_models = models.group_by(&:table_name).slice(*tables).except(*db_habtms)
    db_models.each{ |table_name, models| db_models[table_name] = models.first }
    return db_models, db_habtms
  end

  def get_references model
    bt_associations = model.reflect_on_all_associations.select do |association|
      association.foreign_key.present? && model.columns_hash[association.foreign_key.to_s].present? && column_is_integer?(model, association.foreign_key.to_s)
    end
    bt_associations.map{ |association| association.foreign_key.to_s }
  end

  def column_is_integer? model, name
    model.columns_hash[name].type == :integer
  end
end
