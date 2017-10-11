RailsAdmin.config do |config|
  config.included_models = ['Identity']
  config.authorize_with do
    redirect_to main_app.root_path unless warden.user.is_overlord?
  end
end