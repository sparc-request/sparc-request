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

class SetCwfOrganizations < ActiveRecord::Migration
  def up
    Organization.all.each do |org|
      if org.abbreviation == "Nutrition"
        org.position_in_cwf = 4
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "Nursing"
        org.position_in_cwf = 1
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "Imaging"
        org.position_in_cwf = 3
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "Lab and Biorepistory"
        org.position_in_cwf = 2
        org.show_in_cwf = true
        org.save
      elsif org.abbreviation == "PFT Services"
        org.position_in_cwf = 5
        org.show_in_cwf = true
        org.save
      end
    end
  end

  def down
    Organization.all.each do |org|
      if org.abbreviation == "Nutrition"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "Nursing"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "Imaging"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "Lab and Biorepistory"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      elsif org.abbreviation == "PFT Services"
        org.position_in_cwf = 0
        org.show_in_cwf = false
        org.save
      end
    end
  end
end
