# PB: Added to address error returning from google oauth login
# http://stackoverflow.com/questions/11703679/opensslsslsslerror-on-heroku/16983443#16983443

require 'open-uri'
require 'net/https'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      self.ca_file = Rails.root.join('lib/ca-bundle.crt').to_s
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end
