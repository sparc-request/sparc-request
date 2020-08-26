# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

desc "convert ID column to bigint"
task :migrate_ids_to_bigint => :environment do
  db_models = map_models_to_tablenames

  non_ar_tables = (ApplicationRecord.connection.tables - db_models.keys)
  references = Hash.new{ |h, k| h[k] = [] }
  foreign_keys = Hash.new{ |h, k| h[k] = [] }

  # Reset schemas before making modifications to ensure
  # proper columns are used
  db_models.values.each(&:reset_column_information)

  ApplicationRecord.transaction do
    db_models.each do |table_name, model|
      fks = ApplicationRecord.connection.foreign_keys(table_name)
      foreign_keys[table_name] = fks if fks.present?
      references[table_name] = get_references(model) unless get_references(model).empty?
    end

    foreign_keys.each do |table_name, fks|
      fks.each do |foreign_key|
        ApplicationRecord.connection.remove_foreign_key table_name, name: foreign_key.name
      end
    end

    db_models.select{ |table_name, model| model.primary_key.present? }.each do |table_name, model|
      if column_is_integer? model, model.primary_key
        puts "Updating #{table_name}.#{model.primary_key}"
        ApplicationRecord.connection.change_column table_name, model.primary_key, :bigint, auto_increment: true
      end
    end

    references.each do |table_name, references|
      references.each do |column_name|
        puts "Updating #{table_name}.#{column_name}"
        ApplicationRecord.connection.change_column table_name, column_name, :bigint
      end
    end

    # Reset schemas before adding foreign keys back
    db_models.values.each(&:reset_column_information)

    foreign_keys.each do |table_name, fks|
      fks.each do |foreign_key|
        ApplicationRecord.connection.add_foreign_key table_name, foreign_key.to_table, column: foreign_key.column, primary_key: foreign_key.primary_key
      end
    end

    non_ar_tables.each do |table_name|
      sql_result  = ApplicationRecord.connection.exec_query("SHOW COLUMNS FROM #{table_name}")
      key_index   = sql_result.columns.find_index("Key")
      type_index  = sql_result.columns.find_index("Type")
      name_index  = sql_result.columns.find_index("Field")
      extra_index = sql_result.columns.find_index("Extra")
      reference_columns = sql_result.rows.select{ |row| row[key_index].present? }
      reference_columns.each do |column|
        if column[type_index] == "int(11)"
          opts = {}
          opts[:auto_increment] = true if column[key_index] == 'PRI' && column[extra_index].include?('auto_increment')
          binding.pry if table_name == 'sessions'
          puts "Updating #{table_name}.#{column[name_index]}"
          ApplicationRecord.connection.change_column table_name, column[name_index], :bigint, opts
        end
      end
    end
  end
end

def map_models_to_tablenames
  SparcRails::Application.eager_load! unless SparcRails::Application.config.cache_classes

  tables = ApplicationRecord.connection.tables
  models = ApplicationRecord.descendants
  db_models = models.group_by(&:table_name).slice(*tables)
  db_models.each{ |table_name, models| db_models[table_name] = models.first }
  return db_models
end

def get_references model
  bt_associations = model.reflect_on_all_associations.select do |association|
    (association.foreign_key.present? && model.columns_hash[association.foreign_key.to_s].present? && column_is_integer?(model, association.foreign_key.to_s)) rescue false
  end
  bt_associations.map{ |association| association.foreign_key.to_s }
end

def column_is_integer? model, name
  model.columns_hash[name].sql_type == 'int(11)'
end
