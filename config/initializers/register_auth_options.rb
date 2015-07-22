Rails.application.config.before_initialize do
  providers = YAML.load(ERB.new(File.read(Rails.root.join('config', 'login_providers.yml.erb'))).result)["providers"]
  API::Application.config.auth_providers = providers.keys
end
