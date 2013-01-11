module Portal::AssociatedUsersHelper
  def pre_select_user_credentials(credentials)
    unless credentials.blank?
      selected =  USER_CREDENTIALS.map {|k,v| {pretty_tag(v) => k}}.select{|obj| obj unless obj[pretty_tag(credentials)].blank? }
      selected.blank? ? 'other' : selected.first.try(:keys).try(:first)
    else
      ''
    end
  end

  def reverse_user_credential_hash
    USER_CREDENTIALS.each{|k, v| [v, k]}
  end
end
