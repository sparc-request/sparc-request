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
