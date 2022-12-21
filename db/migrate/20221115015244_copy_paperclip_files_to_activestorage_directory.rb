class CopyPaperclipFilesToActivestorageDirectory < ActiveRecord::Migration[5.2]
  def change
    ActiveStorage::Attachment.find_each do |attachment|
      source = Rails.root.join("public", "system", attachment.blob.key)
      as_prefix_subdir = File.join(attachment.blob.key.first(2), attachment.blob.key.first(4).last(2))
      as_key_subdir = /^(.*[\\\/])/.match(attachment.blob.key)[1]
      dest_dir = Rails.root.join("storage", as_prefix_subdir, as_key_subdir)

      FileUtils.mkdir_p(dest_dir)
      FileUtils.cp(source, dest_dir)
    end
  end
end
