# This file is used by Rack-based servers to start the application.

# PB: This works, but isn't very secure since it makes all project files public
# Also it conflicts with existing /project route
# use Rack::Static, :urls => ["/project"]
# 
# Something like this *should* work and is preferable to above, but isn't working for some reason:
# use Rack::Static, :urls => ["/projectassets"], :root => "project/emigrant/assets"

require ::File.expand_path('../config/environment',  __FILE__)

# use ActionDispatch::Static, '/Users/paulbeaudoin/projects/zoonihack/scribeAPI/project/emigrant/assets'

run Rails.application
