Rails.application.config.middleware.use OmniAuth::Builder do

  providers = YAML.load_file(Rails.root.join('config', 'login_providers.yml'))

  provider :google_oauth2, providers["google"]["id"], providers["google"]["secret"] if providers["google"]
  provider :omniauth, :facebook, providers["facebook"]["id"], providers["facebook"]["secret"]  if providers["facebook"]

end
