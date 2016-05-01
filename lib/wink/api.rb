# api.rb
# Main API class that connects to the wink API
# Wink::API

require 'typhoeus'
require_relative './constants'

module Wink
  ApiBase = 'https://api.wink.com'
  OAuthToken = ENV['WINK_OAUTH_TOKEN']

  # TODO: Remove these if the above constants actually work
  # @@api_base = 'https://api.wink.com'
  # @@oauth_token = ENV['WINK_OAUTH_TOKEN']

  # Now we define some of the helper classes, Request and Response
  # Request is just a simple struct to hold a few pieces of data we need
  class Request
    attr_accessor :endpoint, :method, :params, :body, :headers

    def initialize(endpoint, token, options={})
      puts options
      @endpoint = valid_endpoint(endpoint)
      @method = (options[:method] or HttpMethods.Get) # Method should default to get if possible
      @params = (options[:params] or nil)
      @body = (options[:body] or nil)
      @headers = (options[:headers] or Hash.new).merge auth_header(token) # Merges the oAuth header into the headers passed by the consumer
    end

    def run
      request = setup_request
      return request.run
    end

    def post
      @method = HttpMethods.Post
      run
    end

    def put
      @method = HttpMethods.Put
      run
    end

    def patch
      @method = HttpMethods.Patch
      run
    end

    def delete
      @method = HttpMethods.Delete
      run
    end

    private

    # setup_request: Does the work of actually prepping a typhoeus request
    def setup_request
      return Typhoeus::Request.new(
        endpoint_url,
        method: @method,
        params: @params,
        body: @body,
        headers: @headers)
    end

    # endpoint_url: builds the endpoint URL from api_base (set automatically)
    # and the endpoint set on the request instance
    def endpoint_url
      # @@api_base + @request.endpoint
      ApiBase + @endpoint
    end

    # valid_endpoint: Check to make sure endpoint isn't malformed or missing
    def valid_endpoint(ep)
      if ep == nil
        raise ArgumentError, "Request: An endpoint must be set", caller
      elsif not ep.is_a? String
        raise TypeError, "Request: An endpoint must be a string", caller
      elsif ep.length == 0 # If endpoint was set to ""
        raise TypeError, "Request: Endpoint cannot be empty", caller
      elsif ep[0] != '/'
        raise ArgumentError, "Request: Endpoint must begin with a '/'", caller
      end

      # If we make it to here, we're good - so just return the endpoint
      ep
    end

    # Wink uses oAuth 2.0, this creates a proper oAuth header
    def auth_header(token = nil)
      if token == nil
        # Make sure we have what we need to do this
        if OAuthToken == nil; raise ArgumentError "Request: A token wasn't set, can't make request without a token.", caller; end
        return { Authorization: "Bearer #{OAuthToken}" }
      end

      # Use the passed token if available
      return { Authorization: "Bearer #{token}"}
    end

  end

  # --------------------------------------------------------------------------------
  # --------------------------------------------------------------------------------
  # --------------------------------------------------------------------------------
  # --------------------------------------------------------------------------------

  # Response is a wrapper of sorts for the response object being returned by whatever library we've chosen to use for HTTP requests
  class Response
    # Static Methods
    def self.from_rest_response(rest_response)
      unless rest_response.is_a? self then raise; end
      self.new rest_response.code, rest_response.body, rest_response.headers
    end

    # Instance vars
    attr_reader :code, :data, :body, :headers
    attr_writer :error,

    # Instance methods
    def initialize(code = 404, body = String.new, headers = Hash.new)
      @code = code
      @body = body
      @data = extract_data
      @headers = headers

      if @code >= 400
        raise
      end
    end

    private

    # Helper to extract data from the body of the response
    def extract_data
      begin
        JSON.parse(@body)['data']
      rescue => err
        @error = err
        raise ResponseError, "Attempt to parse response body failed.", caller
      end
    end

    # End of Response class
  end

  # End of Wink Module
end

  # ------------------------------------------------------------
  # ------------------------------------------------------------

=begin
  # Finally, we'll define the heart of the API class
  class API
    attr_accessor :response

    # Static methods
    # Create an API to work with
    def self.create(endpoint, options={})
      request = Request.new(endpoint, options)
      return self.new request
    end

    def self.get(endpoint, params)
      request = Request.new(endpoint, params: params)
      return self.new request
    end

    def initialize(request = Request.new)
      @request = request
      @complete = false # Set complete to false until a response has been received successfully
      @errors = Array.new

      self
    end

    def go
      check_ready
      @response = Response.from_rest_response @request.run
    end

    # def go
    #   # Does the actual work of making a request
    #   begin
    #     # First check to make sure that we are ready
    #     check_ready
    #     response = Response.from_rest_response RestClient.get(endpoint_url, @request.headers.merge auth_header)
    #   rescue ArgumentError => arg_err
    #     @errors.push { error: arg_err, message: arg_err.message }
    #   rescue ResponseError => response_err
    #     if @response.error != nil
    #       @errors.push { type: :Response, error: @response.error, message: @response.error.message }
    #     else
    #       @errors.push { type: :Response, error: response_err, message: response_err.message }
    #     end
    #   rescue => err
    #     @errors.push { type: :unknown, error: err, message: "An error occurred while attempting to contact the wink API" }
    #   end
    #
    #   if @errors.length != 0
    #     # Errors occurred during the GET request
    #     puts @errors.inspect
    #     return nil
    #   end
    #
    #   return response
    # end


    # Private methods to assist the API
    private

    def check_ready
      if @request.endpoint == nil or @request.endpoint.length == 0
        raise ArgumentError 'Endpoint must be specified before calling get' caller
      end
    end
  end

=end
