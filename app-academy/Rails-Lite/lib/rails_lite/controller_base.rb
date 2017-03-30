require 'erb'
require 'active_support/core_ext'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params)
    @request = req
    @response = res
    @route_params = route_params
  end

  def session
    @session ||= Session.new(@request)
  end

  def params
    @params ||= Params.new(@request, @route_params)
  end

  def already_rendered?
    !!@already_built_response
  end

  def redirect_to(url)
    @response.set_redirect(WEBrick::HTTPStatus[302], url)
    session.store_session(@response)
  end

  def render_content(content, type)
    unless already_rendered?
      @already_bult_response = true
      @response.content_type = type
      @response.body = content
      session.store_session(@response)
    end
  end

  def render(template_name)
    erb = ERB.new(File.read("views/#{controller_name.pluralize}/#{template_name}.html.erb"))
    render_content(erb.result(binding), "text/html")
  end

  def controller_name
    name = self.class.to_s.underscore
    name.sub /_controller$/, ''
  end

  def invoke_action(name)
    if methods.include?(name)
      send(name)
    else
      render name
    end
  end

  def method_missing(method_name, *args, &prc)
    if method_name.match(/_url$/)
      method_name.delete("_url")
      UrlHelper.instance.get_url_for(method_name, *args)
    end
  end
end
