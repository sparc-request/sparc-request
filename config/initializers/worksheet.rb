# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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