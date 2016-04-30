# wink_api.rb

require 'rest_client'

module WinkAPI

  Methods = { GET: :get,
              POST: :post,
              PUT: :put,
              PATCH: :patch,
              DELETE: :delete }

  class Request
    attr_accessor :endpoint, :method, :body, :headers

    def initialize(endpoint, options={})
      @endpoint = endpoint
      @method = (options[:method] or Methods.GET)
      @body = options[:body]
      @headers = (options[:headers] or Hash.new)
    end

  end

  class Response
    attr_reader :code, :data, :body, :headers
    attr_writer :error

    def initialize(code = 404, body = String.new, headers = Hash.new)
      @code = code
      @body = body
      @json = JSON.parse(body)
      @data = extract_data
      @headers = headers

      if @code >= 400
        raise
      end
    end

    class << self
      def from_rest_response(rest_response)
        unless rest_response.is_a? self then raise; end
        self.new rest_response.code, rest_response.body, rest_response.headers
      end
    end

    private
    def extract_data
      JSON.parse(@body)['data']
    end


  end


  class API
    @@api_base = 'https://api.wink.com'
    @@oauth_token = ENV['WINK_OAUTH_TOKEN']

    # Request stuff
    attr_accessor :request

    # Response stuff
    attr_accessor :response

    def initialize(request = Request.new)
      @request = request
    end

    def get
      begin
        if @request.endpoint.length == 0; raise ArgumentError 'Endpoint must be specified before calling get' caller; end
        @response = Response.from_rest_response RestClient.get(endpoint_url, @request.headers.merge auth_header)
      rescue ArgumentError
        # TODO:
        # Pick up here tomorrow on rescue
        # What happens? Remember, you don't need to do anything fancy. Just return the data. That's it
      end
    end


    private

    def endpoint_url
      @@api_base + @request.endpoint
    end

    # def merge_headers(addl_header = Hash.new)
    #   if @headers == nil or @headers.count == 0
    #     return auth_header.merge addl_header
    #   end
    #
    #   return @headers.merge auth_header, addl_header
    # end

    # Create auth header in proper format
    def auth_header
      # Make sure we have what we need to do this
      if @@oauth_token == nil; raise; end
      { Authorization: "Bearer #{@@oauth_token}" }
    end

  end
end
