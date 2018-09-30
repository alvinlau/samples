require 'addressable/uri'

module Cardinold
  class URLHelper

    def initialize

    end


    def fetch url
      url = Addressable::URI.parse url
      if url.host.include? 'google'
        # id= hplogo
      end
    end

  end

  # class ChildClass < BaseClass
  #
  #
  # end
end
