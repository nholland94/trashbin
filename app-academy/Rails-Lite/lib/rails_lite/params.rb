require 'uri'
require "json"

class Params
  def initialize(req, route_params)
    @params = route_params
    @params = merge(@params, parse_www_encoded_form(req.query_string)) if req.query_string
    @params = merge(@params, parse_request_body(req)) if req.body
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    result_hash = {}
    URI.decode_www_form(www_encoded_form).each do |pair|
      result_hash[pair.first] = pair.last
    end
    result_hash
  end

  def parse_request_body(req)
    unfiltered_hash = parse_www_encoded_form(req.body)
    filtered_hash = {}
    unfiltered_hash.each do |raw_name, val|
      parsed_keys = parse_key(raw_name)

      build_hash = {}
      last_hash = val

      parsed_keys.reverse.each do |sub_key|
        build_hash[sub_key] = last_hash
        last_hash = build_hash
        build_hash = {}
      end

      filtered_hash = merge(last_hash, filtered_hash)
    end

    filtered_hash
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

  def merge(hash1, hash2)
    result_hash = {}
    [hash1, hash2].each do |hash|
      hash.each do |key, val|
        if result_hash.keys.include?(key) && val.instance_of?(Hash)
          result_hash[key] = merge(hash[key], result_hash[key])
        else
          result_hash[key] = val
        end
      end
    end

    result_hash
  end
end
