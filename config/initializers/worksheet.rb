module Axlsx
  class Worksheet

    # gets column headers from 0 - max (inclusive) for worksheet #
    def get_headers(max)
      (0..max).map{|n| get_header(n)}
    end

    def get_header(num)
      bucket = find_bucket(num)

      i = 1
      while i <= bucket
        num -= 26 ** i
        i += 1
      end

      calculate_components(num, bucket).join("")
    end

    def find_bucket(num)
      if (num < 26)
        return 0
      end

      exp = 1
      check = 26
      while num >= check
        exp += 1
        check += (26 ** exp)
      end

      exp - 1
    end

    def calculate_components(num, bucket)
      chars = ('A'..'Z').to_a
      components = []
      i = bucket
      while i >= 0
        curr_pow = 26 ** i
        component = (num / curr_pow).floor
        components << chars[component]
        num -= (component * curr_pow)
        i -= 1
      end

      components
    end
  end
end