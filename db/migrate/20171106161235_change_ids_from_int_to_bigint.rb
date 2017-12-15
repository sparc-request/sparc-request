class ChangeIdsFromIntToBigint < ActiveRecord::Migration[5.1]
  def change

    db_models, db_habtms = map_models_to_tablenames
    non_ar_tables = (ActiveRecord::Base.connection.tables - db_models.keys - db_habtms)
    references = Hash.new{ |h, k| h[k] = [] }
    foreign_keys = Hash.new{ |h, k| h[k] = [] }
    ActiveRecord::Base.transaction do

      db_models.each do |table_name, model|
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
        change_table(table_name) do |t|
          t.change model.primary_key, :bigint if column_is_integer? model, model.primary_key
          references[table_name].each do |column_name|
            t.change column_name, :bigint if column_is_integer? model, column_name
          end
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
    binding.pry
    db_habtms = models.map{ |model| model.reflect_on_all_associations(:has_and_belongs_to_many) }.compact.flatten.map{ |reflection| reflection.join_table }.uniq
    db_models = (models - [Document]).group_by(&:table_name).slice(*tables).except(*db_habtms)
    db_models.each{ |table_name, models| db_models[table_name] = models.first }
    return db_models.except, db_habtms
  end

  def get_references model
    bt_associations = model.reflect_on_all_associations.select do |association| 
      association.foreign_key.present? && model.columns_hash[association.foreign_key.to_s].present?
    end
    bt_associations.map{ |association| association.foreign_key.to_s }
  end

  def column_is_integer? model, name
    model.columns_hash[name].type == :integer
  end
end
