# https://github.com/ruby/iconv
require 'iconv'

module SanitizedData
  extend ActiveSupport::Concern

  included do
    def self.sanitize_setter attribute, *sanitizers
      define_method("#{attribute.to_s}=") do |value|
        new_value = value.dup

        sanitizers.each do |sanitizer|
          case sanitizer
          when :special_characters
            new_value = Iconv.conv 'UTF-8//IGNORE', 'ascii//TRANSLIT', new_value
          when :epic_special_characters
            new_value.delete! '[]|^'
          when :squeeze
            new_value.squeeze! ' '
          when :strip
            new_value.strip!
          when :squish
            new_value.squish!
          end
        end

        # in development, print out changes
        log_changes(attribute, value, new_value) if Rails.env.development?

        super(new_value)
      end
    end

    private
    def log_changes(attribute, orig_value, new_value)
      puts "#"*50
      puts "Redefined #{attribute.to_s}="
      puts "Original value: '#{orig_value}'"
      puts "New value: '#{new_value}'"
      puts "#"*50
    end
  end
end
