class EpicUser < ActiveResource::Base
  self.site = 'https://c3po-hadoop-s2-v.obis.musc.edu:8484/v1/'
  #https://c3po-hadoop-s2-v.obis.musc.edu:8484/v1/epicintc/viewuser.json?userid=anc63
  #{"UserID"=>"anc63", "IsExist"=>false}
  #{"UserID"=>"wed3", "UserName"=>"Wei Ding", "IsExist"=>true, "IsActive"=>true, "IsBlocked"=>false, "IsPasswordChangeRequired"=>false}

  # force route to use custom collection_name
  def self.collection_name
    @collection_name ||= 'epicintc'
  end
end
