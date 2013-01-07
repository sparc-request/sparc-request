class Identities::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    @identity = Identity.find_for_shibboleth_oauth(request.env["omniauth.auth"], current_identity)

    if @identity.persisted?
      sign_in_and_redirect @identity, :event => :authentication #this will throw if @identity is not activated
      set_flash_message(:notice, :success, :kind => "Shibboleth") if is_navigational_format?
    else
      session["devise.shibboleth_data"] = request.env["omniauth.auth"]
      redirect_to new_identity_registration_url
    end
  end
end

