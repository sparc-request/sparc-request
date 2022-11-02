class RemovePaperclipGeneratedColumnsFromDatabase < ActiveRecord::Migration[5.2]
  def change
    models = [Document, PaymentUpload, Report]

    models.each do |model|
      paperclip_columns = []
      paperclip_columns.concat(model.column_names.grep(/(.+)_file_name$/)).compact
      paperclip_columns.concat(model.column_names.grep(/(.+)_content_type$/)).compact
      paperclip_columns.concat(model.column_names.grep(/(.+)_file_size$/)).compact
      paperclip_columns.concat(model.column_names.grep(/(.+)_updated_at$/)).compact
      if paperclip_columns.empty?
        next
      else
        paperclip_columns.each do |c|
          remove_columns :"#{model.table_name}", :"#{c}"
        end
      end
    end
  end
end
