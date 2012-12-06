require 'multi_json'
require 'formatador'
require 'cl_twitter'

class ItemHandler < ClTwitter::BareHandler
  def initialize
    @formatador = Formatador.new
    super
  end

  def handle(json)
    begin
      hash = MultiJson.decode(json, :symbolize_keys => true)
      return unless hash.is_a?(::Hash)

      if hash[:text] && hash[:user]
        tweet(hash)
      end
    rescue MultiJson::DecodeError
      @formatador.display_line "[red]DecodeError"
      @formatador.indent { @formatador.display_line "#{json}[/]" }
    end
  end

  def tweet(data)
    tweet = Twitter::Tweet.new(data)

    @formatador.display_line "[green]#{tweet.user.name}"
    @formatador.indent { @formatador.display_line "#{tweet.text}[/]" }
  end
end


ClTwitter::Client.track('#thisisatest', ItemHandler.pool).run
