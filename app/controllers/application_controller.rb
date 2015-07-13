class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  def parse_pagination
    @page = get_int :page, 1
    @per_page = get_int :per_page, 20, (1..100)
  end

  # Parse integer out of GET
  # Returns given default if nil or if fails given range
  def get_int(key, default=nil, range=nil)
    return default if params[key].nil? || params[key].class != String
    return default if ! (/^\d+$/ === params[key])
    val = params[key].to_i
    return default if ! range.nil? && ! range.include?(val)
    val
  end

  # Parse (validate) objectid out of GET
  # Returns nil if absent/invalid
  def get_objectid(key)
    return nil if params[key].nil? || ! params[key].is_a?(String)
    return nil if params[key].size != 24 || ! (/^\w+$/ === params[key])
    params[key]
  end


end
