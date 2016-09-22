# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module Capybara::Node::Matchers
  def has_exact_text?(content)
    synchronize do
      unless text == content
        raise Capybara::ExpectationNotMet
      end
    end
    return true
  rescue Capybara::ExpectationNotMet
    return false
  end

  alias_method :has_exact_content?, :has_exact_text?

  def does_not_have_exact_text?(content)
    synchronize do
      if text == content
        raise Capybara::ExpectationNotMet
      end
    end
    return true
  rescue Capybara::ExpectationNotMet
    return false
  end

  alias_method :does_not_have_exact_content?, :does_not_have_exact_text?

  def has_value?(expected)
    synchronize do
      unless value == expected
        raise Capybara::ExpectationNotMet
      end
    end
    return true
  rescue Capybara::ExpectationNotMet
    return false
  end

  def does_not_have_value?(expected)
    synchronize do
      if value == expected
        raise Capybara::ExpectationNotMet
      end
    end
    return true
  rescue Capybara::ExpectationNotMet
    return false
  end
end

module Capybara::RSpecMatchers
  class HaveExactText
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def matches?(actual)
      @actual = wrap(actual)
      @actual.has_exact_text?(text)
    end

    def does_not_match?(actual)
      @actual = wrap(actual)
      @actual.does_not_have_exact_text?(text)
    end

    def failure_message
      "expected #{format(text)} to equal #{format(@actual.text)}"
    end

    def failure_message__when_negated
      "expected #{format(text)} to not equal #{format(@actual.text)}"
    end

    def description
      "equal #{format(text)}"
    end

    def wrap(actual)
      if actual.respond_to?("has_selector?")
        actual
      else
        Capybara.string(actual.to_s)
      end
    end

    def format(text)
      text = Capybara::Helpers.normalize_whitespace(text) unless text.is_a? Regexp
      text.inspect
    end
  end

  def have_exact_content(text)
    HaveExactText.new(text)
  end

  def have_exact_text(text)
    HaveExactText.new(text)
  end

  def does_not_have_exact_content(text)
    HaveExactText.new(text)
  end

  def does_not_have_exact_text(text)
    HaveExactText.new(text)
  end

  class HaveValue
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def matches?(actual)
      @actual = wrap(actual)
      @actual.has_value?(value)
    end

    def does_not_match?(actual)
      @actual = wrap(actual)
      @actual.does_not_have_exact_value?(value)
    end

    def failure_message
      "expected #{format(value)} to equal #{format(@actual.value)}"
    end

    def failure_message_when_negated
      "expected #{format(value)} to not equal #{format(@actual.value)}"
    end

    def description
      "equal #{format(value)}"
    end

    def wrap(actual)
      if actual.respond_to?("has_selector?")
        actual
      else
        Capybara.string(actual.to_s)
      end
    end

    def format(value)
      value = Capybara::Helpers.normalize_whitespace(value) unless value.is_a? Regexp
      value.inspect
    end
  end

  def have_value(value)
    HaveValue.new(value)
  end

  def does_not_have_value(value)
    HaveValue.new(value)
  end
end
