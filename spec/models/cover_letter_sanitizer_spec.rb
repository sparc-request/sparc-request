require 'spec_helper'

describe CoverLetterSanitizer do
  subject(:sanitizer){ CoverLetterSanitizer.new }
  it 'strips out <em> tags, but leaves the contents of those tags' do
    sanitizer.sanitize("<p>hello <em>world</em></p>").should == "<p>hello world</p>"
  end
end
