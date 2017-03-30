require 'json'
require 'webrick'

class Session
  def initialize(req)
    cookies = req.cookies.select { |cookie| cookie.name == "_rails_lite_app" }

    if cookies.empty?
      @cookie_data = {}
    else
      @cookie_data = JSON.parse(cookies.first)
    end
  end

  def [](key)
    @cookie_data[key]
  end

  def []=(key, val)
    @cookie_data[key] = val
  end

  def store_session(res)
    res.cookies << @cookie_data.to_json
  end
end
