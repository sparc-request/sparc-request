class CoverLetterSanitizer < HTML::WhiteListSanitizer
  self.allowed_tags = HTML::WhiteListSanitizer.allowed_tags - %w(em)
end