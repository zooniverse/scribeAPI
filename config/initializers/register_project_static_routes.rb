API::Application.configure do
  project_assets_path = "./project/#{Project.current.key}/assets"
  puts "Routing static assets from #{project_assets_path}"
  Rails.application.config.middleware.insert_after ActionDispatch::Static, ActionDispatch::Static, project_assets_path
end
