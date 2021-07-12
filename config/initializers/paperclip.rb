# Disable timestamps added to Paperclip URLs. Prevents Chrome and Edge from altering
# the file extension of downloads to match the Content-Type header, which can prevent
# Word from opening older-format documents.
Paperclip::Attachment.default_options[:use_timestamp] = false
