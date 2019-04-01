# Copyright © 2011-2019 MUSC Foundation for Research Development
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

require "rails_helper"

RSpec.describe DataTypeValidator do

  include DataTypeValidator

  describe '#is_boolean?' do
    it 'should allow true' do
      expect(is_boolean?('true')).to eq(true)
    end

    it 'should allow false' do
      expect(is_boolean?('false')).to eq(true)
    end

    it 'should not allow other values' do
      expect(is_boolean?('wrong')).to eq(false)
    end
  end

  describe '#is_json?' do
    it 'should allow valid json strings' do
      expect(is_json?('{"key":"value"}')).to eq(true)
    end

    it 'should not allow invalid json' do
      expect(is_json?('{:key => "value"}')).to eq(false)
    end
  end

  describe '#is_email?' do
    it 'should allow valid email' do
      expect(is_email?('myname@email.com')).to eq(true)
    end

    it 'should allow valid comma-separated emails' do
      expect(is_email?('person1@musc.edu, person2@musc.edu')).to eq(true)
    end

    it 'should not allow invalid email' do
      expect(is_email?('my.name.email.com')).to eq(false)
    end
  end

  describe '#is_url?' do
    it 'should allow valid https urls' do
      expect(is_url?('https://sparc.musc.edu/dashboard/protocols/')).to eq(true)
    end

    it 'should allow valid http urls' do
      expect(is_url?('http://sparc.musc.edu/dashboard/protocols/')).to eq(true)
    end

    it 'should allow valid url without protocol' do
      expect(is_url?('sparc.musc.edu/dashboard/protocols/')).to eq(true)
    end

    it 'should allow url with port' do
      expect(is_url?('localhost:3000/dashboard/protocols/')).to eq(true)
    end

    it 'should not allow a partial path' do
      expect(is_url?('/dashboard/')).to eq(false)
    end
  end

  describe '#is_path?' do
    it 'should allow a valid path' do
      expect(is_path?('/dashboard/?service_request_id=1&admin=false')).to eq(true)
    end

    it 'should not allow an invalid path' do
      expect(is_path?('https://sparc.musc.edu/dashboard/?service_request_id=1&admin=false')).to eq(false)
    end
  end

  describe '#get_type' do
    it 'should return the data type' do
      expect(get_type('true')).to eq('boolean')
      expect(get_type('{"key":"value"}')).to eq('json')
      expect(get_type('myname@email.com')).to eq('email')
      expect(get_type('https://sparc.musc.edu/dashboard/protocols/')).to eq('url')
      expect(get_type('/dashboard/?service_request_id=1&admin=false')).to eq('path')
    end
  end
end
