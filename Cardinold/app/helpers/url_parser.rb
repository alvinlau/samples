require 'public_suffix'
require 'addressable/uri'

# https://github.com/weppos/publicsuffix-ruby

module Cardinold
  class URL

    def self.parse url
      src = url

      # alternatively do https://stackoverflow.com/a/16359999
      begin
        url = Addressable::URI.heuristic_parse(url).normalize
      rescue Addressable::URI::InvalidURIError
        return nil
      end

      PublicSuffix.valid? url.host

      mongo = Mongo::Client.new('mongodb://127.0.0.1:27017/test')
      hosts = mongo[:hosts]
      sites = mongo[:sites]

      matches = hosts.find({host: url.host})
      unless matches.any? # add to new hosts
        new_hosts = mongo[:new_hosts]
        new_hosts.insert_one({host: url.host, source: src})
        return nil
      end
      host = matches.first

      site = sites.find({name: host[:name]}).first
      apps = site[:apps].select{|app| (url.host + url.path).include? app[:path]}

      if apps.empty? # new app
        new_apps = mongo[:new_apps]
        new_apps.insert_one({site: site, url: url})
        return nil
      end

      app = apps.first

      response = Typhoeus.get(url, followlocation: true)
      return nil if !response.success?
      return nil if response.timed_out?
      response.code

      html = response.body

      {site: site[:name], app: app[:path], html: html}
    end


  end

end
