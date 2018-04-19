class BotUser < User

  AUTH_HEADER = 'HTTP_BOT_AUTH'

  # Create bot user with name
  def self.create(name)
    user = find_or_initialize_by name: name, role: 'bot'
    token = ''
    if ! user.persisted?
      token = user.reset_token!
    end
    {user: user, token: token}
  end

  # Immediately overwrite existing token with a new one
  def reset_token!
    token = Devise.friendly_token[0,20]
    self.password = self.password_confirmation = token
    self.email = "#{name}@scribe"
    save! validate: false
    token
  end

  def self.pack_auth_header(user_id, token)
    [user_id, token].join ":"
  end

  def self.unpack_auth_header(str)
    str.split ":"
  end

  # Given hash of headers, return bot user if a header authenticates
  def self.by_auth(headers)
    # No header? Fail.
    return nil if headers[AUTH_HEADER].blank?

    # Fail if header doesn't have two values:
    parts = unpack_auth_header headers[AUTH_HEADER]
    return nil if parts.size != 2

    # Get user by name and auth using token:
    user = find parts[0]
    return nil if ! user.valid_password? parts[1]

    user
  end
end
