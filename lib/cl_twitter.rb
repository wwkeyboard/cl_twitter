require "cl_twitter/version"

require 'celluloid'
require 'twitter'
require 'oauth'

# borrowed from https://github.com/laughing/Ruby-Twitter-Stream/blob/master/lib/twitterstream.rb
module Net
  class HTTPResponse
    def each_line(rs = "\n")
      stream_check
      while line = @socket.readuntil(rs)
        yield line
      end
      self
    end
  end
end

module ClTwitter
  class Client
    attr_reader :uri, :params, :handler_pool

    def initialize(new_uri, new_params, new_handler_pool)
      @uri = new_uri
      @params = new_params
      @handler_pool = new_handler_pool
    end

    def self.track(terms, new_handler_pool)
      self.new(URI("https://stream.twitter.com/1.1/statuses/filter.json"),
               {track: terms},
               new_handler_pool)
    end

    def run
      begin
        http.request(request(uri, params)) do |response|
          response.each_line("\r\n") do |line|
            line.chomp!
            handler_pool.handle(line) if line.length > 0
          end
        end
      ensure
        http.finish
      end
    end

    def http
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE)
    end

    def request(uri, params)
      Net::HTTP::Post.new(uri.request_uri).tap do |r|
        r.set_form_data(params) if params
        r.oauth!(http, oauth_consumer, oauth_access)
      end
    end

    def oauth_consumer
      OAuth::Consumer.new(ENV["CONSUMER_TOKEN"], ENV["CONSUMER_SECRET"])
    end

    def oauth_access
      OAuth::Token.new(ENV["ACCESS_TOKEN"], ENV["ACCESS_SECRET"])
    end
  end

  class Handler
    include Celluloid
  end
end
