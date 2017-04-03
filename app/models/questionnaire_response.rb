class QuestionnaireResponse < ApplicationRecord
  belongs_to :submission
  belongs_to :item
  validates :content, presence: true, if: :required? 
  validates_format_of :content, with: Devise::email_regexp, allow_blank: true, if: :content_is_email?

  def required?
    required == true
  end

  def content_is_email?
    (item.item_type == 'email') if item
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
