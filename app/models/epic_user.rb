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

class EpicUser < ActiveResource::Base
  self.site = Setting.get_value('epic_user_endpoint')
  #https://c3po-hadoop-s2-v.obis.musc.edu:8484/v1/epicintc/viewuser.json?userid=anc63
  #{"UserID"=>"anc63", "IsExist"=>false}
  #{"UserID"=>"wed3", "UserName"=>"Wei Ding", "IsExist"=>true, "IsActive"=>true, "IsBlocked"=>false, "IsPasswordChangeRequired"=>false}

  # force route to use custom collection_name
  def self.collection_name
    @collection_name ||= Setting.get_value('epic_user_collection_name')
  end

  def self.for_identity(identity)
    get(:viewuser, userid: identity.ldap_uid.split('@').first)
  end

  def self.is_active?(epic_user)
    epic_user && epic_user.key?('IsActive') && epic_user['IsActive']
  end
end
