require "active_support/inflector"
require "webrick"

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.path.match(@pattern) && req.request_method.downcase == http_method.downcase
  end

  def run(req, res)
    params = {}
    match_data = req.path.match(@pattern)
    match_data.names.each do |name|
      params[name.to_sym] = match_data[name]
    end

    @controller_class.new(req, res, params).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(path, method, controller_class, action_name, options = {})
    url_sections = path.split(/\//)

    pattern_text = ""
    url_sections.each do |section|
      if section.first == ":"
        section.delete(":")
        pattern_text += "/(?<#{section}>\\[^\/]+)"
      else
        pattern_text += "/#{section}"
      end
    end

    pattern = Regexp.new("^#{pattern_text}$")

    unless options[:as].nil?
      UrlHelper.instance.add_url(options[:as], path)
    end

    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  def resources(name)
    base_url = name
    new_url = "#{name}/new"
    edit_url = "#{name}/edit"
    id_url = "#{name}/:id"
    controller = Kernel.const_get("#{name.singularize.capitalize}Controller")

    draw do
      get base_url, controller, :index, as: "users"
      post base_url, controller, :create
      get id_url, controller, :show, as: "user"
      get new_url, controller, :new, as: "new_user"
      get edit_url, controller, :edit, as: "edit_user"
      put base_url, controller, :update
      delete base_url, controller, :destroy
    end
  end

  ["get", "post", "put", "delete"].each do |method|
    define_method(method) do |path, controller_class, action_name|
      add_route(path, method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end

    nil
  end

  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = WEBrick::HTTPStatus[404]
    end
  end
end
