class QuestionnaireResponse < ActiveRecord::Base
  belongs_to :submission
  belongs_to :item
  # validates :content, presence: true, if: :required? 
  validates_format_of :content, with: Devise::email_regexp, if: :content_is_email?
  validates_format_of :content, with: /\d{3}-\d{3}-\d{4}/, if: :content_is_number?

  def required?
    required == true
  end

  def content_is_email?
    item.item_type == 'email'
  end

  def content_is_number?
    item.item_type == 'number'
  end

  # When content == '["a","b", "c"]',
  # return ['a', 'b', 'c'].
  def content_as_array
    begin
      # '["a","b", "c"]' -> '"a","b","c"'
      no_brackets = content[1...-1]

      # '"a","b","c"' -> ['"a"', '"b"', '"c"']
      quoted_elements = no_brackets.split(", ")

      # ['"a"', '"b"', '"c"'] -> ['a', 'b', 'c']
      quoted_elements.map { |quoted_elt| quoted_elt[1...-1] }
    rescue
      []
    end
  end
end
