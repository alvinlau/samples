module Meshie
  class BaseItem
    Accepted_fields = %w[uuid type]

    def sanitize src
      # use activesupport's slice if we bring in activesupport
      # http://api.rubyonrails.org/v3.2/classes/Hash.html#method-i-slice
      src.select { |key,_| self::Accepted_fields.include? key }
      # error! if ....
    end
  end

  class LinkItem < BaseItem
    Accepted_fields = %w[uuid type url url_type item_name]
    attr_reader :json

    def initialize src
      json = sanitize src
    end
  end
end
