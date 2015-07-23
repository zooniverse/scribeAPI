Rails.application.config.before_initialize do
  providers = YAML.load(ERB.new(File.read(Rails.root.join('config', 'login_providers.yml.erb'))).result)["providers"]

  provider_keys = []
  providers.each do |k,v| 
    if ! v['id'].blank? && ! v['secret'].blank?
      provider_keys << k
    end
  end

  API::Application.config.auth_providers = provider_keys
  puts "Init: OAUTH providers: #{API::Application.config.auth_providers}"
end
