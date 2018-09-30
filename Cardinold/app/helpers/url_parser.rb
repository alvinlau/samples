# Helper methods defined here can be accessed in any controller or view in the application
require "addressable/uri"

module Cardinold
  class URL

    def self.parse uri
      uri = Addressable::URI.parse(uri).normalize

      uri.scheme

      uri.host

      uri.path

      return
    end


  end

end
