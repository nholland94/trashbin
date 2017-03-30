require 'singleton'

class UrlHelper
  include Singleton

  def initialize
    @url_hash = {}
  end

  def add_url(name, url)
    @url_hash[name] = url
  end

  def get_url_for(name, *args)
    if args.empty?
      return @url_hash[name]
    else
      url_sections = @url_hash[name].split(/\//)

      url = ""
      url_sections.each do |section|
        if section.first == ":"
          section.delete(":")
          url += "/#{args.shift}"
        else
          url += "/#{section}"
        end
      end

      return url
    end
  end

end