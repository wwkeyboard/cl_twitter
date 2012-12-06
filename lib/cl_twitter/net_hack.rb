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

