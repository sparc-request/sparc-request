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

module Dashboard::ApplicationHelper

  def format_date date
    if date.present?
      date.strftime('%D')
    else
      ''
    end
  end

  def format_datetime date
    if date.present?
      date.strftime('%D %I:%M %p')
    else
      ''
    end
  end

  def display_if to_compare_1, to_compare_2=true
    if to_compare_1 == to_compare_2
      return { style: "display: block;" }
    else
      return { style: "display: none;" }
    end
  end

  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def two_decimal_places(num)
    sprintf('%0.2f', num.to_f.round(2)) rescue nil
  end

  def cents_to_dollars(cost)
    cost / 100.00 rescue nil
  end

  def cents_to_dollars_float cost
    number_with_precision(cents_to_dollars(cost), precision: 2) || number_with_precision(0, precision: 2)
  end

  def display_as_percent(percent_subsidy)
    (percent_subsidy * 100.0).round(2) rescue nil
  end

  def display_user_role(user)
    user.role == 'other' ? user.role_other.humanize : user.role.humanize
  end

  def truncate_string_length(s, max=70, elided = ' ...')
    #truncates string to max # of characters then adds elipsis
    if s.present?
      s.match( /(.{1,#{max}})(?:\s|\z)/ )[1].tap do |res|
        res << elided unless res.length == s.length
      end
    else
      ""
    end
  end
end
